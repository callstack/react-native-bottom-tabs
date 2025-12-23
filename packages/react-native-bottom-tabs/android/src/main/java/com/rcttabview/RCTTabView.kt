package com.rcttabview

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.transition.TransitionManager
import android.util.Log
import android.util.Size
import android.util.TypedValue
import android.view.Choreographer
import android.view.HapticFeedbackConstants
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.forEachIndexed
import coil3.ImageLoader
import coil3.asDrawable
import coil3.request.ImageRequest
import coil3.svg.SvgDecoder
import coil3.size.Precision
import coil3.size.Size as CoilSize
import coil3.size.Scale
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.assets.ReactFontManager
import com.facebook.react.modules.core.ReactChoreographer
import com.facebook.react.views.text.ReactTypefaceUtils
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.navigation.NavigationBarView.LABEL_VISIBILITY_AUTO
import com.google.android.material.navigation.NavigationBarView.LABEL_VISIBILITY_LABELED
import com.google.android.material.navigation.NavigationBarView.LABEL_VISIBILITY_UNLABELED
import com.google.android.material.transition.platform.MaterialFadeThrough

class ExtendedBottomNavigationView(context: Context) : BottomNavigationView(context) {
  override fun getMaxItemCount(): Int {
    return 100
  }
}

class ReactBottomNavigationView(context: Context) : LinearLayout(context) {
  private var bottomNavigation = ExtendedBottomNavigationView(context)
  val layoutHolder = FrameLayout(context)

  var onTabSelectedListener: ((key: String) -> Unit)? = null
  var onTabLongPressedListener: ((key: String) -> Unit)? = null
  var onNativeLayoutListener: ((width: Double, height: Double) -> Unit)? = null
  var onTabBarMeasuredListener: ((height: Int) -> Unit)? = null
  var disablePageAnimations = false
  var items: MutableList<TabInfo> = mutableListOf()
  private val iconSources: MutableMap<Int, ImageSource> = mutableMapOf()
  private val drawableCache: MutableMap<ImageSource, Drawable> = mutableMapOf()

  private var isLayoutEnqueued = false
  private var selectedItem: String? = null
  private var activeTintColor: Int? = null
  private var inactiveTintColor: Int? = null
  private val checkedStateSet = intArrayOf(android.R.attr.state_checked)
  private val uncheckedStateSet = intArrayOf(-android.R.attr.state_checked)
  private var hapticFeedbackEnabled = false
  private var fontSize: Int? = null
  private var fontFamily: String? = null
  private var fontWeight: Int? = null
  private var labeled: Boolean? = null
  private var lastReportedSize: Size? = null
  private var hasCustomAppearance = false
  private var uiModeConfiguration: Int = Configuration.UI_MODE_NIGHT_UNDEFINED

  private val imageLoader = ImageLoader.Builder(context)
    .components {
      add(SvgDecoder.Factory())
    }
    .build()

  init {
    orientation = VERTICAL

    addView(
      layoutHolder, LayoutParams(
        LayoutParams.MATCH_PARENT,
        0,
      ).apply { weight = 1f }
    )
    layoutHolder.isSaveEnabled = false

    addView(bottomNavigation, LayoutParams(
      LayoutParams.MATCH_PARENT,
      LayoutParams.WRAP_CONTENT
    ))
    uiModeConfiguration = resources.configuration.uiMode

    post {
      addOnLayoutChangeListener { _, left, top, right, bottom,
                                  _, _, _, _ ->
        val newWidth = right - left
        val newHeight = bottom - top

        // Notify about tab bar height.
        onTabBarMeasuredListener?.invoke(Utils.convertPixelsToDp(context, bottomNavigation.height).toInt())

        if (newWidth != lastReportedSize?.width || newHeight != lastReportedSize?.height) {
          val dpWidth = Utils.convertPixelsToDp(context, layoutHolder.width)
          val dpHeight = Utils.convertPixelsToDp(context, layoutHolder.height)

          onNativeLayoutListener?.invoke(dpWidth, dpHeight)
          lastReportedSize = Size(newWidth, newHeight)
        }
      }
    }
  }

  private val layoutCallback = Choreographer.FrameCallback {
    isLayoutEnqueued = false
    refreshLayout()
  }

  private fun refreshLayout() {
    measure(
      MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY),
    )
    layout(left, top, right, bottom)
  }

  fun applyDirection(dir: Int) {
      bottomNavigation.layoutDirection = dir   
  }

  override fun requestLayout() {
    super.requestLayout()
    @Suppress("SENSELESS_COMPARISON") // layoutCallback can be null here since this method can be called in init

    if (!isLayoutEnqueued && layoutCallback != null) {
      isLayoutEnqueued = true
      // we use NATIVE_ANIMATED_MODULE choreographer queue because it allows us to catch the current
      // looper loop instead of enqueueing the update in the next loop causing a one frame delay.
      ReactChoreographer
        .getInstance()
        .postFrameCallback(
          ReactChoreographer.CallbackType.NATIVE_ANIMATED_MODULE,
          layoutCallback,
        )
    }
  }

  fun setSelectedItem(value: String) {
    selectedItem = value
    setSelectedIndex(items.indexOfFirst { it.key == value })
  }

  override fun addView(child: View, index: Int, params: ViewGroup.LayoutParams?) {
    if (child === layoutHolder || child === bottomNavigation) {
      super.addView(child, index, params)
      return
    }

    val container = createContainer()
    container.addView(child, params)
    layoutHolder.addView(container, index)

    val itemKey = items[index].key
    if (selectedItem == itemKey) {
      setSelectedIndex(index)
      refreshLayout()
    }
  }

  private fun createContainer(): FrameLayout {
    val container = FrameLayout(context).apply {
      layoutParams = FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
      isSaveEnabled = false
      visibility = GONE
      isEnabled = false
    }
    return container
  }

  private fun setSelectedIndex(itemId: Int) {
    bottomNavigation.selectedItemId = itemId
    if (!disablePageAnimations) {
      val fadeThrough = MaterialFadeThrough()
      TransitionManager.beginDelayedTransition(layoutHolder, fadeThrough)
    }

    layoutHolder.forEachIndexed { index, view ->
      if (itemId == index) {
        toggleViewVisibility(view, true)
      } else {
        toggleViewVisibility(view, false)
      }
    }

    layoutHolder.requestLayout()
    layoutHolder.invalidate()
  }

  private fun toggleViewVisibility(view: View, isVisible: Boolean) {
    check(view is ViewGroup) { "Native component tree is corrupted." }

    view.visibility = if (isVisible) VISIBLE else GONE
    view.isEnabled = isVisible
  }

  private fun onTabSelected(item: MenuItem) {
    val selectedItem = items[item.itemId]
    selectedItem.let {
      onTabSelectedListener?.invoke(selectedItem.key)
      emitHapticFeedback(HapticFeedbackConstants.CONTEXT_CLICK)
    }
  }

  private fun onTabLongPressed(item: MenuItem) {
    val longPressedItem = items[item.itemId]
    longPressedItem.let {
      onTabLongPressedListener?.invoke(longPressedItem.key)
      emitHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
    }
  }

  fun setTabBarHidden(isHidden: Boolean) {
    if (isHidden) {
      bottomNavigation.visibility = GONE
    } else {
      bottomNavigation.visibility = VISIBLE
    }
  }

  fun updateItems(items: MutableList<TabInfo>) {
    // If an item got removed, let's re-add all items
    if (items.size < this.items.size) {
      bottomNavigation.menu.clear()
    }
    this.items = items
    items.forEachIndexed { index, item ->
      val menuItem = getOrCreateItem(index, item.title)
      if (item.title !== menuItem.title) {
        menuItem.title = item.title
      }

      menuItem.isVisible = !item.hidden
      if (iconSources.containsKey(index)) {
        getDrawable(iconSources[index]!!) {
          menuItem.icon = it
        }
      }

      if (item.badge?.isNotEmpty() == true) {
        val badge = bottomNavigation.getOrCreateBadge(index)
        badge.isVisible = true
        // Set the badge text only if it's different than an empty space to show a small badge.
        // More context: https://github.com/callstackincubator/react-native-bottom-tabs/issues/422
        if (item.badge != " ") {
          badge.text = item.badge
        }
        // Apply badge colors if provided (Material will use its default theme colors otherwise)
        item.badgeBackgroundColor?.let { badge.backgroundColor = it }
        item.badgeTextColor?.let { badge.badgeTextColor = it }
      } else {
        bottomNavigation.removeBadge(index)
      }
      post {
        val itemView = bottomNavigation.findViewById<View>(menuItem.itemId)
        itemView?.let { view ->
          view.setOnLongClickListener {
            onTabLongPressed(menuItem)
            true
          }
          view.setOnClickListener {
            onTabSelected(menuItem)
          }

          item.testID?.let { testId ->
            view.findViewById<View>(com.google.android.material.R.id.navigation_bar_item_content_container)
              ?.apply {
                tag = testId
              }
          }
        }
      }
    }
    // Update tint colors and text appearance after updating all items.
    post {
      updateTextAppearance()
      updateTintColors()
    }
  }

  private fun getOrCreateItem(index: Int, title: String): MenuItem {
    return bottomNavigation.menu.findItem(index) ?: bottomNavigation.menu.add(0, index, 0, title)
  }

  fun setIcons(icons: ReadableArray?) {
    if (icons == null || icons.size() == 0) {
      return
    }

    for (idx in 0 until icons.size()) {
      val source = icons.getMap(idx)
      val uri = source?.getString("uri")
      if (uri.isNullOrEmpty()) {
        continue
      }

      val imageSource = ImageSource(context, uri)
      this.iconSources[idx] = imageSource

      // Update existing item if exists.
      bottomNavigation.menu.findItem(idx)?.let { menuItem ->
        getDrawable(imageSource) {
          menuItem.icon = it
        }
      }
    }
  }

  fun setLabeled(labeled: Boolean?) {
    this.labeled = labeled
    bottomNavigation.labelVisibilityMode = when (labeled) {
      false -> {
        LABEL_VISIBILITY_UNLABELED
      }
      true -> {
        LABEL_VISIBILITY_LABELED
      }
      else -> {
        LABEL_VISIBILITY_AUTO
      }
    }
  }

  fun setRippleColor(color: ColorStateList) {
    bottomNavigation.itemRippleColor = color
  }

  @SuppressLint("CheckResult")
  private fun getDrawable(imageSource: ImageSource, onDrawableReady: (Drawable?) -> Unit) {
    drawableCache[imageSource]?.let {
      onDrawableReady(it)
      return
    }
    val iconSizePx = bottomNavigation.itemIconSize
    val request = ImageRequest.Builder(context)
      .data(imageSource.getUri(context))
      .size(CoilSize(iconSizePx, iconSizePx))
      .scale(Scale.FILL)
      .precision(Precision.EXACT)
      .target { drawable ->
        post {
          val stateDrawable = drawable.asDrawable(context.resources)
          drawableCache[imageSource] = stateDrawable
          onDrawableReady(stateDrawable)
        }
      }
      .listener(
        onError = { _, result ->
          Log.e("RCTTabView", "Error loading image: ${imageSource.uri}", result.throwable)
        }
      )
      .build()

    imageLoader.enqueue(request)
  }

  fun setBarTintColor(color: Int?) {
    // Set the color, either using the active background color or a default color.
    val backgroundColor =
      color ?: Utils.getDefaultColorFor(context, android.R.attr.colorPrimary) ?: return

    // Apply the same color to both active and inactive states
    val colorDrawable = ColorDrawable(backgroundColor)

    bottomNavigation.itemBackground = colorDrawable
    bottomNavigation.backgroundTintList = ColorStateList.valueOf(backgroundColor)
    hasCustomAppearance = true
  }

  fun setActiveTintColor(color: Int?) {
    activeTintColor = color
    updateTintColors()
  }

  fun setInactiveTintColor(color: Int?) {
    inactiveTintColor = color
    updateTintColors()
  }

  fun setActiveIndicatorColor(color: ColorStateList) {
    bottomNavigation.itemActiveIndicatorColor = color
  }

  fun setFontSize(size: Int) {
    fontSize = size
    updateTextAppearance()
  }

  fun setFontFamily(family: String?) {
    fontFamily = family
    updateTextAppearance()
  }

  fun setFontWeight(weight: String?) {
    val fontWeight = ReactTypefaceUtils.parseFontWeight(weight)
    this.fontWeight = fontWeight
    updateTextAppearance()
  }

  fun onDropViewInstance() {
    imageLoader.shutdown()
  }

  private fun updateTextAppearance() {
    // Early return if there is no custom text appearance
    if (fontSize == null && fontFamily == null && fontWeight == null) {
      return
    }

    val typeface = if (fontFamily != null || fontWeight != null) {
      ReactFontManager.getInstance().getTypeface(
        fontFamily ?: "",
        Utils.getTypefaceStyle(fontWeight),
        context.assets
      )
    } else null
    val size = fontSize?.toFloat()?.takeIf { it > 0 }

    val menuView = bottomNavigation.getChildAt(0) as? ViewGroup ?: return
    for (i in 0 until menuView.childCount) {
      val item = menuView.getChildAt(i)
      val largeLabel =
        item.findViewById<TextView>(com.google.android.material.R.id.navigation_bar_item_large_label_view)
      val smallLabel =
        item.findViewById<TextView>(com.google.android.material.R.id.navigation_bar_item_small_label_view)

      listOf(largeLabel, smallLabel).forEach { label ->
        label?.apply {
          size?.let { size ->
            setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
          }
          typeface?.let { setTypeface(it) }
        }
      }
    }
  }

  private fun emitHapticFeedback(feedbackConstants: Int) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && hapticFeedbackEnabled) {
      this.performHapticFeedback(feedbackConstants)
    }
  }

  private fun updateTintColors() {
    // First let's check current item color.
    val currentItemTintColor = items.firstOrNull { it.key == selectedItem }?.activeTintColor

    // getDefaultColor will always return a valid color but to satisfy the compiler we need to check for null
    val colorPrimary = currentItemTintColor ?: activeTintColor ?: Utils.getDefaultColorFor(
      context,
      android.R.attr.colorPrimary
    ) ?: return
    val colorSecondary =
      inactiveTintColor ?: Utils.getDefaultColorFor(context, android.R.attr.textColorSecondary)
      ?: return
    val states = arrayOf(uncheckedStateSet, checkedStateSet)
    val colors = intArrayOf(colorSecondary, colorPrimary)

    ColorStateList(states, colors).apply {
      this@ReactBottomNavigationView.bottomNavigation.itemTextColor = this
      this@ReactBottomNavigationView.bottomNavigation.itemIconTintList = this
    }
  }

  override fun onConfigurationChanged(newConfig: Configuration?) {
    super.onConfigurationChanged(newConfig)
    if (uiModeConfiguration == newConfig?.uiMode || hasCustomAppearance) {
      return
    }

    // User has hidden the bottom navigation bar, don't re-attach it.
    if (bottomNavigation.visibility == GONE) {
      return
    }

    // If appearance wasn't changed re-create the bottom navigation view when configuration changes.
    // React Native opts out ouf Activity re-creation when configuration changes, this workarounds that.
    // We also opt-out of this recreation when custom styles are used.
    removeView(bottomNavigation)
    bottomNavigation = ExtendedBottomNavigationView(context)
    addView(bottomNavigation)
    updateItems(items)
    setLabeled(this.labeled)
    this.selectedItem?.let { setSelectedItem(it) }
    uiModeConfiguration = newConfig?.uiMode ?: uiModeConfiguration
  }
}

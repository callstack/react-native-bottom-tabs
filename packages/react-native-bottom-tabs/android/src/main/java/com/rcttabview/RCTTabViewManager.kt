package com.rcttabview

import android.content.res.ColorStateList
import android.view.View
import android.view.ViewGroup
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.RNCTabViewManagerDelegate
import com.facebook.react.viewmanagers.RNCTabViewManagerInterface
import com.rcttabview.events.OnNativeLayoutEvent
import com.rcttabview.events.OnTabBarMeasuredEvent
import com.rcttabview.events.PageSelectedEvent
import com.rcttabview.events.TabLongPressEvent

data class TabInfo(
  val key: String,
  val title: String,
  val badge: String?,
  val badgeBackgroundColor: Int?,
  val badgeTextColor: Int?,
  val activeTintColor: Int?,
  val hidden: Boolean,
  val testID: String?
)


@ReactModule(name = RCTTabViewManager.NAME)
class RCTTabViewManager(context: ReactApplicationContext) :
  ViewGroupManager<ReactBottomNavigationView>(),
  RNCTabViewManagerInterface<ReactBottomNavigationView> {

  private val delegate: RNCTabViewManagerDelegate<ReactBottomNavigationView, RCTTabViewManager> =
    RNCTabViewManagerDelegate(this)

  override fun createViewInstance(context: ThemedReactContext): ReactBottomNavigationView {
    val view = ReactBottomNavigationView(context)
    val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(context, view.id)
    view.onTabSelectedListener = { key ->
      eventDispatcher?.dispatchEvent(PageSelectedEvent(viewTag = view.id, key))
    }

    view.onTabLongPressedListener = { key ->
      eventDispatcher?.dispatchEvent(TabLongPressEvent(viewTag = view.id, key))
    }

    view.onNativeLayoutListener = { width, height ->
      eventDispatcher?.dispatchEvent(OnNativeLayoutEvent(viewTag = view.id, width, height))
    }
    view.onTabBarMeasuredListener = { height ->
      eventDispatcher?.dispatchEvent(OnTabBarMeasuredEvent(viewTag = view.id, height))
    }
    return view

  }

  override fun onDropViewInstance(view: ReactBottomNavigationView) {
    super.onDropViewInstance(view)
    view.onDropViewInstance()
  }

  override fun getName(): String {
    return NAME
  }

  override fun getChildCount(parent: ReactBottomNavigationView): Int {
    return parent.layoutHolder.childCount ?: 0
  }

  override fun getChildAt(parent: ReactBottomNavigationView, index: Int): View? {
    return parent.layoutHolder.getChildAt(index)
  }

  override fun removeView(parent: ReactBottomNavigationView, view: View) {
    parent.layoutHolder.removeView(view)
  }

  override fun removeAllViews(parent: ReactBottomNavigationView) {
    parent.layoutHolder.removeAllViews()
  }

  override fun removeViewAt(parent: ReactBottomNavigationView, index: Int) {
    parent.layoutHolder.removeViewAt(index)
  }

  override fun needsCustomLayoutForChildren(): Boolean {
    return true
  }

  override fun setItems(view: ReactBottomNavigationView?, value: ReadableArray?) {
    if (view != null && value != null) {
      val itemsArray = mutableListOf<TabInfo>()
      for (i in 0 until value.size()) {
        value.getMap(i)?.let { item ->
            itemsArray.add(
              TabInfo(
                key = item.getString("key") ?: "",
                title = item.getString("title") ?: "",
                badge = if (item.hasKey("badge")) item.getString("badge") else null,
                badgeBackgroundColor = if (item.hasKey("badgeBackgroundColor")) item.getInt("badgeBackgroundColor") else null,
                badgeTextColor = if (item.hasKey("badgeTextColor")) item.getInt("badgeTextColor") else null,
                activeTintColor = if (item.hasKey("activeTintColor")) item.getInt("activeTintColor") else null,
                hidden = if (item.hasKey("hidden")) item.getBoolean("hidden") else false,
                testID = item.getString("testID")
              )
            )
        }
      }
      view.updateItems(itemsArray)
    }
  }

  override fun setSelectedPage(view: ReactBottomNavigationView?, value: String?) {
    if (view != null && value != null)
      view.setSelectedItem(value)
  }

  override fun setIcons(view: ReactBottomNavigationView?, value: ReadableArray?) {
    if (view != null)
      view.setIcons(value)
  }

  override fun setLabeled(view: ReactBottomNavigationView?, value: Boolean) {
    if (view != null)
      view.setLabeled(value)
  }

  override fun setRippleColor(view: ReactBottomNavigationView?, value: Int?) {
    if (view != null && value != null) {
      val color = ColorStateList.valueOf(value)
      view.setRippleColor(color)
    }
  }

  override fun setBarTintColor(view: ReactBottomNavigationView?, value: Int?) {
    if (view != null && value != null)
      view.setBarTintColor(value)
  }

  override fun setActiveTintColor(view: ReactBottomNavigationView?, value: Int?) {
    if (view != null && value != null)
      view.setActiveTintColor(value)
  }

  override fun setInactiveTintColor(view: ReactBottomNavigationView?, value: Int?) {
    if (view != null && value != null)
      view.setInactiveTintColor(value)
  }

  override fun setActiveIndicatorColor(view: ReactBottomNavigationView?, value: Int?) {
    if (view != null && value != null) {
      val color = ColorStateList.valueOf(value)
      view.setActiveIndicatorColor(color)
    }
  }

  override fun getDelegate(): ViewManagerDelegate<ReactBottomNavigationView> {
    return delegate
  }

  override fun setHapticFeedbackEnabled(view: ReactBottomNavigationView?, value: Boolean) {
    if (view != null)
      view.isHapticFeedbackEnabled = value
  }

  override fun setLayoutDirection(view: ReactBottomNavigationView, value: String?) {
      val direction = when (value) {
          "rtl" -> View.LAYOUT_DIRECTION_RTL
          "ltr" -> View.LAYOUT_DIRECTION_LTR
          else -> View.LAYOUT_DIRECTION_LOCALE
      }
      view.applyDirection(direction)
  }

  override fun setFontFamily(view: ReactBottomNavigationView?, value: String?) {
    view?.setFontFamily(value)
  }

  override fun setFontWeight(view: ReactBottomNavigationView?, value: String?) {
    view?.setFontWeight(value)
  }

  override fun setFontSize(view: ReactBottomNavigationView?, value: Int) {
    view?.setFontSize(value)
  }

  override fun setDisablePageAnimations(view: ReactBottomNavigationView?, value: Boolean) {
    view?.disablePageAnimations = value
  }

  override fun setTabBarHidden(view: ReactBottomNavigationView?, value: Boolean) {
    view?.setTabBarHidden(value)
  }

  // iOS Methods
  override fun setTranslucent(view: ReactBottomNavigationView?, value: Boolean) {
  }

  override fun setSidebarAdaptable(view: ReactBottomNavigationView?, value: Boolean) {
  }

  override fun setScrollEdgeAppearance(view: ReactBottomNavigationView?, value: String?) {
  }

  override fun setMinimizeBehavior(view: ReactBottomNavigationView?, value: String?) {
  }

  companion object {
    const val NAME = "RNCTabView"
  }
}

import Badge from '../components/Badge';

const getPageData = (page) => {
  // existing code...

  if (page.badges) {
    page.badges = page.badges.map((badge) => (
      <Badge key={badge.text} text={badge.text} type={badge.type} />
    ));
  }

  return page;
};

export default getPageData;
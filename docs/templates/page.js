import React from 'react';
import { graphql } from 'gatsby';
import Layout from '../components/Layout';
import Badge from '../components/Badge';

const PageTemplate = ({ data }) => {
  const { mdx } = data;
  const { frontmatter, body } = mdx;

  return (
    <Layout>
      <div>
        {frontmatter.badges && (
          <div>
            {frontmatter.badges.map((badge) => (
              <Badge key={badge.text} text={badge.text} type={badge.type} />
            ))}
          </div>
        )}
        <div dangerouslySetInnerHTML={{ __html: body }} />
      </div>
    </Layout>
  );
};

export const query = graphql`
  query($slug: String!) {
    mdx(fields: { slug: { eq: $slug } }) {
      frontmatter {
        badges {
          text
          type
        }
      }
      body
    }
  }
`;

export default PageTemplate;
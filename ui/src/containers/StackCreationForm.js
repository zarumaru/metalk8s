import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { injectIntl } from 'react-intl';
import { Formik, Form } from 'formik';
import * as yup from 'yup';
import styled from 'styled-components';
import isEmpty from 'lodash.isempty';
import { Breadcrumb, Input, Button } from '@scality/core-ui';
import { padding } from '@scality/core-ui/dist/style/theme';

import {
  BreadcrumbContainer,
  BreadcrumbLabel,
  StyledLink,
} from '../components/BreadcrumbStyle';
import { createStackAction } from '../ducks/app/solutions';

const StackCreationFormContainer = styled.div`
  display: inline-block;
  padding: ${padding.base};
`;

const CreationFormContainer = styled.div`
  margin-top: ${padding.base};
`;

const TextAreaContainer = styled.div`
  display: inline-flex;
`;

const TextAreaLabel = styled.label`
  width: 200px;
  align-self: flex-start;
  padding: 10px;
  font-size: 14px;
`;

/**
 * width = 200px - ${padding.smaller} - ${border} * 2
 */
const TextArea = styled.textarea`
  width: 188px;
  border-radius: 4px;
  border: 1px solid #87929d;
  padding: ${padding.smaller};
`;

const ActionContainer = styled.div`
  display: flex;
  margin: ${padding.large} 0;
  justify-content: flex-end;
  button {
    margin-right: ${padding.large};
  }
`;

const FormSection = styled.div`
  display: flex;
  padding: 0 ${padding.larger};
  flex-direction: column;

  .sc-input {
    display: inline-flex;
    margin: ${padding.smaller} 0;
    .sc-input-label {
      width: 200px;
    }
    .sc-input-wrapper {
      width: 200px;
    }
  }
`;

const StackCreationForm = props => {
  const { intl } = props;
  const dispatch = useDispatch();
  const theme = useSelector(state => state.config.theme);

  const initialValues = {
    name: '',
    description: '',
  };

  const validationSchema = {
    name: yup.string().required(),
    description: yup.string(),
  };

  return (
    <StackCreationFormContainer>
      <BreadcrumbContainer>
        <Breadcrumb
          activeColor={theme.brand.secondary}
          paths={[
            <StyledLink to="/solutions">{intl.messages.solutions}</StyledLink>,
            <BreadcrumbLabel>{intl.messages.create_new_stack}</BreadcrumbLabel>,
          ]}
        />
      </BreadcrumbContainer>
      <CreationFormContainer>
        <Formik
          initialValues={initialValues}
          validationSchema={validationSchema}
          onSubmit={values => {
            dispatch(createStackAction(values));
          }}
        >
          {formikProps => {
            const { handleChange, errors, dirty } = formikProps;

            return (
              <Form>
                <FormSection>
                  <Input
                    name="name"
                    label={intl.messages.name}
                    onChange={handleChange('name')}
                  />
                  <TextAreaContainer>
                    <TextAreaLabel>{intl.messages.description}</TextAreaLabel>
                    <TextArea
                      name="description"
                      rows="4"
                      onChange={handleChange}
                    />
                  </TextAreaContainer>
                </FormSection>

                <ActionContainer>
                  <Button text={intl.messages.cancel} type="button" outlined />
                  <Button
                    text={intl.messages.create}
                    type="submit"
                    disabled={!dirty || !isEmpty(errors)}
                    data-cy="submit-create-stack"
                  />
                </ActionContainer>
              </Form>
            );
          }}
        </Formik>
      </CreationFormContainer>
    </StackCreationFormContainer>
  );
};

export default injectIntl(StackCreationForm);

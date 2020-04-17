import axios from 'axios';

const csrfToken = document.querySelector('[name=csrf-token]').content
axios.defaults.headers.common['X-CSRF-TOKEN'] = csrfToken

const get = () => {
  return axios.get('/api/v1/hierarchies');
}

export default {
  get,
};

/**
 * Summary. emit data to fiveM client side
 *
 * @param {string} resource resource name
 * @param {string} event client event registered
 * @param {any} data data to send to client
 */
export const emitClient = async (resource, event, data = {}) => {
  const url = `https://${resource}/${event}`;
  const resp = await fetch(url, {
    method: "POST",
    mode: 'cors', // defaults to same-origin
    headers: {
      'Accept': 'application/json',
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  }).then((resp) => resp.json());
  return resp;
};
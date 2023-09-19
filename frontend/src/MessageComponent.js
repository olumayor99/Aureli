import React, { useState, useEffect } from 'react';

const MessageComponent = () => {
  const [message, setMessage] = useState('');
  useEffect(() => {
      fetch(process.env.REACT_APP_BACKEND_URL)
         .then((response) => {
            if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
         .then((data) => {
            console.log(data);
            setMessage(data.message);
         })
         .catch((err) => {
            console.log(err.message);
         });
   }, []);

  return (
    <div>
      <h1>-----Message from the Backend-----</h1>
      <p>{message}</p>
    </div>
  );
};

export default MessageComponent;
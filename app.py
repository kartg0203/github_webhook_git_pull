from flask import Flask, request, jsonify
import subprocess
import hashlib
import hmac

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    """
    Endpoint for receiving webhook events from GitHub.

    This function handles the POST request sent by GitHub when a webhook event occurs.
    It verifies the token, retrieves the payload data, and executes a shell command based on the action and repository name.

    Returns:
        A JSON response with the status and output/error message.

    Raises:
        None
    """
    success, message = verify_signature(request.data, 'your_secret_token', request.headers.get('x-hub-signature-256'))
    if success == False:
        return jsonify({'status': 'error', 'message': message}), 403

    data = request.get_json()
    if data:

        repository_name = data.get('repository', {}).get('name')
        branch_name = '/'.join(data.get('ref').split('/')[2:])
        # print(f"{repository_name} repository on the {branch_name} branch", flush=True)
        command = f"./git_pull.sh {repository_name} {branch_name}"
        process = subprocess.run(command, shell=True, capture_output=True, text=True)
        # print(process.stdout, flush=True)

        if process.returncode == 0:
            return jsonify({'status': 'success', 'output': process.stdout})
        else:
            return jsonify({'status': 'error', 'error': process.stderr}), 500
    return jsonify({'status': 'error', 'message': 'Invalid payload'}), 400


def verify_signature(payload_body, secret_token, signature_header):
    """
    Verify the signature of a webhook payload.

    Args:
        payload_body (str): The body of the webhook payload.
        secret_token (str): The secret token used to sign the payload.
        signature_header (str): The signature header received in the webhook request.

    Returns:
        tuple: A tuple containing a boolean indicating whether the signature is valid and a string with an error message if the signature is invalid.
    """
    if not signature_header:
        return False, 'x-hub-signature-256 header is missing!'

    hash_object = hmac.new(secret_token.encode('utf-8'), msg=payload_body, digestmod=hashlib.sha256)
    expected_signature = "sha256=" + hash_object.hexdigest()

    if not hmac.compare_digest(expected_signature, signature_header):
        return False, 'Request signatures didn\'t match!'
    return True, ''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

from flask import Flask, request, jsonify
import subprocess

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
    # token = request.args.get('token')
    # if token != 'YOUR_SECRET_TOKEN':
    #     return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

import argparse
import bottle
import socket

from bottle import run, route

app = bottle.default_app()

@route('/')
def hello():
  hostname = socket.gethostname()
  return "Hello World! I am {hostname}".format(hostname=hostname)

@route('/health')
def health():
  return "healthy"

def main():
  parser = argparse.ArgumentParser(description='Starts a simple web service')
  parser.add_argument('--port', type=int, metavar=('<port>'), default=8080, help='Port number to listen on')
  parser.add_argument('--debug', action="store_true", default=False, help='Debug mode')
  args = parser.parse_args()
  run(host='0.0.0.0', port=args.port, debug=args.debug)

if __name__ ==  "__main__":
  main()
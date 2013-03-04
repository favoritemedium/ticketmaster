import argparse
import getpass
import requests
import json

# newticket.py - submit a ticket to Favorite Medium's Unfuddle.
#
# For a list of options, do:  python newticket.py -h

parser = argparse.ArgumentParser(description="Submit a ticket to Favorite Medium's Unfuddle.",epilog="The user will be prompted for any parameters not specified on the command line.")
parser.add_argument("-u", "--username", help="Unfuddle username")
parser.add_argument("--password", help="Unfuddle password")
parser.add_argument("-p", "--projectid", type=int, help="Project ID (number)", default=313388) # default to nexant
parser.add_argument("-s", "--summary", help="Ticket summary")
parser.add_argument("-d", "--description", help="Ticket description")
parser.add_argument("-q", "--quiet", help="suppress output", action="store_true")
args = parser.parse_args()

username = args.username if args.username else raw_input("Unfuddle username: ")
password = args.password if args.password else getpass.getpass("Unfuddle password: ")


# prompt for the project ID if it's somehow missing (should never happen)
if not args.projectid:
  projectid = int(raw_input("Project ID: "))


# otherwise only prompt for the project ID if we're also prompting for the summary and/or description
else:
  projectid = args.projectid
  if not args.summary or not args.description:
    x = raw_input("Project ID (%i): " % projectid)
    if x.isdigit():
      projectid = int(x)


summary = args.summary if args.summary else raw_input("Ticket summary: ")
description = args.description if args.description else raw_input("Ticket description: ")


# go

r = requests.post(
  'https://favmed.unfuddle.com/api/v1/projects/%i/tickets' % projectid,
  auth = (username,password),
  headers = {'Accept':'application/json', 'Content-Type':'application/xml'},
  data = "<ticket><summary>%s</summary><description>%s</description><priority>3</priority></ticket>" % (summary, description)
)


# caller feedback

if not args.quiet:

  if r.status_code == 201:
    print "Ticket created."

  elif r.status_code == 401:
    print "Authentication error."

  elif r.status_code == 400:
    for err in json.loads(r.text):
      print "Error: "+err
    print "No ticket created."

  else:
    print "Error "+r.status_code


exit(0 if r.status_code == 201 else 1)

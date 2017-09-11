import os, sys
from subprocess import Popen, PIPE

def integ_files(op,src,dest):

  operation = 'integ -o'
  if op == 'copy':
    operation = 'copy'
  
  elif op == 'merge':
    operation = 'merge'
  
  op_cmd = ['p4', operation, src, dest]

  try:
    (eout,eerr) = Popen(op_cmd,stdin=PIPE,stdout=PIPE).communicate()
    print eout

  except Exception, e:
    print e

  submit_cmd = ['p4','submit','-d', op + '_' + src + 'to' + dest]

  try:
    (sout,serr) = Popen(submit_cmd,stdin=PIPE,stdout=PIPE).communicate()
    print sout

  except Exception, e:
    print e


def main():

  if len(sys.argv) != 4:
    usage_msg = "Usage: " + sys.argv[0] + " <operation> <src> <dest>"
    print(usage_msg.center(80))
    msg = "e.g. python " + sys.argv[0] + " integ //depot/main/... //depot/rel/..."
    print(msg.center(80))
    print
    sys.exit(1)

  op = sys.argv[1]; src = sys.argv[2]; dest = sys.argv[3]
  integ_files(op,src,dest)

if __name__ == '__main__': main()

import os, sys
from subprocess import Popen, PIPE

def add_files(fileList):

  for each_file in fileList:

      f = open(each_file,"w")
      f.writelines("Test" + each_file + "\n")
      f.close()

      edit_cmd = ['p4','add', each_file]

      try:
        (eout,eerr) = Popen(edit_cmd,stdin=PIPE,stdout=PIPE).communicate()
        print eout
        #print eerr

      except Exception, e:
        print e

      submit_cmd = ['p4','submit','-d','add file ' + each_file ]

      try:
        (sout,serr) = Popen(submit_cmd,stdin=PIPE,stdout=PIPE).communicate()
        print sout
        #print serr

      except Exception, e:
        print e


def main():

  if len(sys.argv) != 2:
    usage_msg = "Usage: " + sys.argv[0] + " fileList"
    print(usage_msg.center(80))
    msg = "e.g. python " + sys.argv[0] + " a,aa,aaa,aaaa"
    print(msg.center(80))
    print
    sys.exit(1)

  fileList = sys.argv[1].split(',')
  add_files(fileList)

if __name__ == '__main__': main()

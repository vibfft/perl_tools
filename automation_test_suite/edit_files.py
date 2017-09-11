import os, sys
from subprocess import Popen, PIPE

def edit_files(number, fileList):

  for each_file in fileList:
    for i in range(number):

      edit_cmd = ['p4','edit', each_file]

      try:
        (eout,eerr) = Popen(edit_cmd,stdin=PIPE,stdout=PIPE).communicate()
        print eout
        #print eerr

      except Exception, e:
        print e
      
      try:
        f = open(each_file,"a")
        f.writelines("Test" + str(i) + "\n")
        f.close()

      except Exception, e:
        print e

      submit_cmd = ['p4','submit','-d','edit ' + str(number) + ' times']

      try:
        (sout,serr) = Popen(submit_cmd,stdin=PIPE,stdout=PIPE).communicate()
        print sout
        #print serr

      except Exception, e:
        print e


def main():

  if len(sys.argv) != 3:
    usage_msg = "Usage: " + sys.argv[0] + " <num_edits> fileList"
    print(usage_msg.center(80))
    msg = "e.g. python " + sys.argv[0] + " 5 a,aa,aaa,aaaa"
    print(msg.center(80))
    print
    sys.exit(1)

  fileList = sys.argv[2].split(',')
  edit_files(int(sys.argv[1]),fileList)

if __name__ == '__main__': main()

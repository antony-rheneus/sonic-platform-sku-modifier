#!/usr/bin/python


import os
import sys
import subprocess

sys.path.append("/usr/lib/cgi-bin/sonic_helper")

def fn_local_exec_v1(command, arg1):
    proc = subprocess.Popen([command, arg1], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        #outs, errs = proc.communicate()
        out = [x.strip() for x in proc.stdout.readlines()]
    except:
        proc.kill()
        outs, errs = proc.communicate()
        print ("Error/Timed out")
    	print (errs.decode('UTF-8').rstrip())
    #print (outs.decode('UTF-8').rstrip())
    #out = [nl.strip() for nl in outs.decode('UTF-8').rstrip()]	
    #out=outs.decode('UTF-8').rstrip()
    return out


def fn_ssh_exec(ip, user, passwd, command):
    proc = subprocess.Popen(['/usr/bin/sshpass', '-p', passwd, 'ssh', user + '@' + ip , command], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        #outs, errs = proc.communicate()
        out = [x.strip() for x in proc.stdout.readlines()]
    except:
        proc.kill()
        outs, errs = proc.communicate()
        print ("Error/Timed out")
    	print (errs.decode('UTF-8').rstrip())
    #print (outs.decode('UTF-8').rstrip())
    #out = [nl.strip() for nl in outs.decode('UTF-8').rstrip()]	
    #out=outs.decode('UTF-8').rstrip()
    return out


def fn_ssh_copy(ip, user, passwd, path, file_to_copy):
    proc = subprocess.Popen(['/usr/bin/sshpass', '-p', passwd, 'scp', path + file_to_copy,  user + '@' + ip  +":/tmp/_"+file_to_copy], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        outs, errs = proc.communicate()
    except:
        proc.kill()
        outs, errs = proc.communicate()
        print ("Error/Timed out")
    	print (errs.decode('UTF-8').rstrip())
    #print (outs.decode('UTF-8').rstrip())


#
# Test code

def fn_test_me():
    global out
    out = []
    fn_ssh_copy("10.111.60.15", "admin", "Innovium123", "/var/www/cgi-bin/sonic_helper/", "remote_hwsku_info.sh")
    out = fn_ssh_exec("10.111.60.15", "admin", "Innovium123", "/tmp/_remote_hwsku_info.sh")
    #print out
    #print len(out)

if __name__ == "__main__":
    fn_test_me()

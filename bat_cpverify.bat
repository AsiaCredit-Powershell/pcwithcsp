chcp=1251
echo off 

cd "C:\Program Files\Crypto Pro\CSP\"
cpverify.exe -rm system

cd "C:\Program Files\Crypto Pro\CSP\"
cpverify.exe -rv 

cpverify -addreg -file «C:\Windows\SysWOW64\inetcomm.dll»
cpverify -addreg -file «C:\Windows\SysWOW64\schannel.dll»
cpverify -addreg -file «C:\Windows\SysWOW64\wininet.dll»
cpverify -addreg -file «C:\Windows\SysWOW64\certenroll.dll»
cpverify -addreg -file «C:\Windows\system32\certenroll.dll»
cpverify -addreg -file «C:\Windows\system32\schannel.dll»
cpverify -addreg -file «C:\Windows\system32\wininet.dll»
cpverify -addreg -file «C:\Windows\system32\msi.dll»
cpverify -addreg -file «C:\Windows\system32\inetcomm.dll»
cpverify -addreg -file «C:\Windows\system32\sspicli.dll»
cpverify -addreg -file «C:\Windows\system32\crypt32.dll»
cpverify -addreg -file «C:\Windows\system32\kerberos.dll»

start cpverify -addreg -file "C:\WINDOWS\system32\crypt32.dll"
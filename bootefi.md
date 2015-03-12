# AppleTV boot.efi #

AppleTV boot.efi
```
00000000h: B9 FA F1 0E 02 00 00 00 07 00 00 00 03 00 00 00 30 00 00 00 D8 3F 02 00 00 00 00 00 07 00 00 01
00000020h: 03 00 00 00 08 40 02 00 28 4F 02 00 00 00 00 00  
```


OS X 10.4.8 boot.efi
```
00000000h: B9 FA F1 0E 02 00 00 00 07 00 00 00 03 00 00 00 30 00 00 00 21 0D 02 00 00 00 00 00 07 00 00 01
00000020h: 03 00 00 00 51 0D 02 00 17 13 02 00 00 00 00 00
```



0x00	 B9 FA F1 0E	 Magic number? 0xEF1FAB9 looks like leetspeak
0x04	 02 00 00 00	 Unknown
0x08	 07 00 00 00	 Unknown
0x0B	 03 00 00 00	 Unknown
0xF0	 30 00 00 00	 Offset (in bytes) to beginning of first executable's header ( = 48 dec)
0xF4	 D8 3F 02 00	 Length (in bytes) of first executable ( = 147416 dec)
0xF8	 00 00 00 00	 Unknown (end of record?)
0xFB	 07 00 00 01	 Unknown
0x20	 03 00 00 00	 Unknown
0x24	 08 40 02 00	 Offset (in bytes) to beginning of second executable's header ( = 147464 dec)
0x28	 28 4f 02 00	 Length (in bytes) of first executable ( = 151336 dec)
0x3B	 00 00 00 00	 Unknown (end of record?)




PE Sections

If the AppleTV boot.efi is split according to the information in the proprietary header, the result is two valid and distinct PE files. Interestingly, the seldom-used checksum field in the "Optional Header" is filled in here (see Section 3.4.2 of the PE/COFF spec above). Combined with the fact that a single-byte change to a safe region of the file (ie, a string resource) is enough to keep the AppleTV from booting successfully, this suggests that the firmware is validating the checksum before beginning execution.
These checksums are not calculated in the usual manner. None of the freely available EFI executables (elilo, refit, Intel reference shell implementation, etc) have a checksum value specified at all, although this knowledge is basically useless without knowing the method for calculating the proper checksum.




each section have 32+256+256 bytes optional data, from 0x23de8(first section) 0x48e30(second section


boot.efi(appletv)
0x23de8-0x23e07 fingerprint of public key (sha-256 of public key+?)
0x23e08-0x23f07 public key, 1024 bit, little-endian => n
0x23f08-0x24007 signature,  1024 bit, little-endian => a



I think these bytes consist from 32bytes are SHA-256 checksum of PE executable
19bytes (30 31 30 0d 06... in big endian) are prefix for RSA/SHA-256,
see PKCS 2.1 (rfc3447) for detail. rests are stuffing bytes

Here is a program to display above bytes:
```
// g++ checkefi.cc -o checkefi -lssl
#include <stdio.h>
#include <stdlib.h>
#include <openssl/bn.h>
unsigned char * fileread(char fname[], int ofs, int sz)
{
  FILE *fp= fopen(fname, "r");
  if(fp==0) perror(fname), exit(1);
  fseek(fp, ofs, SEEK_SET);
  unsigned char* buf= (unsigned char*)malloc(sz);
  fread(buf, 1, sz, fp);
  fclose(fp);
  for(int i= sz/2; --i>=0;) { //little endian->big endian
    unsigned char c= buf[i]; buf[i]= buf[sz-1-i]; buf[sz-1-i]= c;
  }
  return buf;
}
main()
{
  BIGNUM *e= BN_new(), *n= BN_new(), *a= BN_new(), *b= BN_new();
  BN_set_word(e, 65537);
  BN_bin2bn(fileread("boot.efi", 0x23e08, 0x100), 0x100, n);
  BN_bin2bn(fileread("boot.efi", 0x23f08, 0x100), 0x100, a);
  BN_mod_exp(b, a, e, n, BN_CTX_new());
  unsigned char buf[1000];
  int sz= BN_bn2bin(b, buf);
  for(int i= 0; i<sz; i++) { //big endian->little endian
    printf("%02x ", buf[sz-1-i]);
    if(i%16==15) printf("\n");
  }
  printf("\n");
}

```
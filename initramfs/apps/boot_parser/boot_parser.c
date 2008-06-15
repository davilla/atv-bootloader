/* boot_parser.c - Main source
 * Copyright (C) 2008 Scott D. Davilla <davilla@4pi.com>
 * All rights reserved.

 *  boot_parser is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as 
 *  published by the Free Software Foundation
 
   This boot_parser inputs grub, kboot, syslinux, isolinux and mb_boot_tv
   boot configuration files and outputs a kexec load string. 
	For example;
		boot_parser --root=/mnt/rootfs --config=/mnt/rootfs/boot/grub/menu.lst
		boot_parser --root=/mnt/rootfs --config=/mnt/rootfs/boot/kboot.conf
		boot_parser --root=/mnt/rootfs --config=/mnt/rootfs/syslinux.cfg
		boot_parser --root=/mnt/rootfs --config=/mnt/rootfs/isolinux.cfg
		boot_parser --root=/mnt/rootfs --config=/mnt/rootfs/mb_boot_tv.cfg
	
	where;
		--root is the mount point for the kexec booted filesystem (where vmlinux/initrd live)
		--config is the path to the bootloader conf file.
 */
//
//
// C includes
#include	<stdlib.h>
#include	<stdio.h>
#include 	<string.h>

#define IS_WHITESPACE(x) (x == ' ' || x == '\t' || x == '\n' || x == '\r')

typedef struct _KEXEC_ENTRY {
	char		title[256];
	char		kernel[256];
	char		initrd[256];
	char		cmdline[256];
} KEXEC_ENTRY;

//________________________________________________________________________________
int	parse_int_argv(const char *argv, const char *param_str, int *param);
int	parse_str_argv(const char *argv, const char *param_str, char *param);
char*	freadline(char *bp, int n, FILE *fp);
//
int	parse_line(char *line, char *name, char *value);
void	parse_grub(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec);
void	parse_kboot(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec);
void	parse_syslinux(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec);
void	parse_mb_boot_tv(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec);
//________________________________________________________________________________
//________________________________________________________________________________
int main (int argc, const char *argv[]) {
	int				i;
	char			tmp_str[1024];
		
	char			io_root[1024];
	char			io_filename[1024];
	KEXEC_ENTRY		io_kexec;

	//__________________________________________________________
	// default input params
	strcpy(io_root, "");
	strcpy(io_filename, "");
	//strcpy(io_filename, "/boot/grub/menu.lst");
	//strcpy(io_filename, "/boot/mb_boot_tv.conf");
	//strcpy(io_filename, "menu.lst");
	//strcpy(io_filename, "/syslinux.cfg");
	//strcpy(io_filename, "/mb_boot_tv.conf");
	
	//__________________________________________________________
	//__________________________________________________________
	// Check command line arguments
	// argv[0] is application path so we really get n+1 for argc
	for (i = 1; i < argc; i++) {
		if ( strstr(argv[i], "--root=") ) {
			strcpy(tmp_str, "");
			if ( parse_str_argv(argv[i], "--root=", tmp_str) ) {
				if (strlen(tmp_str) ) {
					strcpy(io_root, tmp_str);
				} else {
					fprintf(stdout, "argument error %s\n", argv[i]);
					return(-1);
				}
			}
			//
		} else if ( strstr(argv[i], "--config=") ) {
			strcpy(tmp_str, "");
			if ( parse_str_argv(argv[i], "--config=", tmp_str) ) {
				if (strlen(tmp_str) ) {
					strcpy(io_filename, tmp_str);
				} else {
					fprintf(stdout, "argument error %s\n", argv[i]);
					return(-1);
				}
			}
			//
		} else if ( strstr(argv[i], "--help") ) {
			fprintf(stdout, "A command line tool for parsing boot configs\n");
			fprintf(stdout, "Handles kboot.conf, grub.conf, menu.lst, syslinux.conf and ioslinux.conf\n");
			fprintf(stdout, "\n");
			fprintf(stdout, "example: ./kexec_auto_boot --root=/boot --config=/boot/grub/menu.lst --label=default\\\n");
			fprintf(stdout, "\n");
			fprintf(stdout, "Command line arguments:\n");
			fprintf(stdout, "\n");
			fprintf(stdout, "--root=root where root is a path mounted filesystem\n");
			fprintf(stdout, "--config=filename where filename is a path to a boot configuration\n");
		}
	}

	//__________________________________________________________
	//__________________________________________________________
	if ( strstr(io_filename, "kboot.conf") ) {
		parse_kboot(io_root, io_filename, &io_kexec);
		//
	} else if ( strstr(io_filename, "grub.conf") ) {
		parse_grub(io_root, io_filename, &io_kexec);
	} else if ( strstr(io_filename, "menu.lst" ) ) {
		parse_grub(io_root, io_filename, &io_kexec);
		//
	} else if ( strstr(io_filename, "syslinux.cfg") ) {
		parse_syslinux(io_root, io_filename, &io_kexec);
	} else if ( strstr(io_filename, "isolinux.cfg") ) {
		parse_syslinux(io_root, io_filename, &io_kexec);
		//
	} else if ( strstr(io_filename, "mb_boot_tv.conf") ) {
		parse_mb_boot_tv(io_root, io_filename, &io_kexec);
	}

	//__________________________________________________________
	//__________________________________________________________
	if ( strlen(io_kexec.kernel) ) {
		char			kexec_load_str[512];
		
		// default kexec output string
		strcpy(kexec_load_str, "");
	
		// now we can create the kexec load command
		// if no kernel token, we are done
		if (strlen( io_kexec.kernel) ) {
			sprintf(kexec_load_str, "kexec --load %s ", io_kexec.kernel);
		} else {
			return(0);
		}
		//
		strcpy(tmp_str, "");
		if (strlen( io_kexec.initrd) ) {
			sprintf(tmp_str, "--initrd=%s ", io_kexec.initrd);
		}
		strcat(kexec_load_str, tmp_str);
		//
		strcpy(tmp_str, "");
		if (strlen( io_kexec.cmdline) ) {
			sprintf(tmp_str, "--command-line=\"%s\"", io_kexec.cmdline);
		}
		strcat(kexec_load_str, tmp_str);
		//
		fprintf(stdout, "%s\n", kexec_load_str);
	}
	
    return(0);
}
//________________________________________________________________________________
//________________________________________________________________________________
//________________________________________________________________________________
int
parse_int_argv(const char *argv, const char *param_str, int *param)
{
	char		*str_ptr;
	
	str_ptr = (char*)strcasestr(argv, param_str);
	
	if (str_ptr) {
		str_ptr = (char*)strcasestr(argv, "=");
		if (str_ptr) {
			str_ptr++;
		
			*param = atoi(str_ptr);
		}
	}
		
	return(str_ptr != NULL);
}
//________________________________________________________________________________
int
parse_str_argv(const char *argv, const char *param_str, char *param)
{
	char		*str_ptr;
	
	str_ptr = (char*)strcasestr(argv, param_str);
	
	if (str_ptr) {
		str_ptr = (char*)strcasestr(argv, "=");
		if (str_ptr) {
			str_ptr++;
		
			strcpy(param, str_ptr);
		}
	}
		
	return(str_ptr != NULL);
}
//________________________________________________________________________________
// works like fgets but handles Mac/PC/UNIX line ending formats
char*
freadline(char *bp, int n, FILE *fp)
{
	char			*str = bp;
	int				c = '\0';
	int				c2 = '\0';
    int				cndx = 0;
    int				nndx;
    
   	// Read one line from the source file (leave space for nil terminator)
    for (nndx=0; nndx < n-1; nndx++) {
    	c = getc(fp);
    	switch(c) {
    		// \r first terminator
    		case '\r':
    			// Test for extra terminator ('\r\n')
    			c2 = getc(fp);
    			if (c2 != EOF) {
    				// if no '\n' then done, if yes '\n', eat it.
    				if (c2 != '\n') {
    					ungetc(c2, fp);
    				}
				}
    			//bp[cndx++] = '\n';
    			bp[cndx]   = '\0';
            	return(str);
    		// \n first terminator
    		case '\n':
    			// Test for extra terminator ('\n\r')
    			c2 = getc(fp);
    			if (c2 != EOF) {
    				// if no '\r' then done, if yes '\r', eat it.
    				if (c2 != '\r') {
    					ungetc(c2, fp);
    				}
				}
    			//bp[cndx++] = '\n';
    			bp[cndx]   = '\0';
        		return(str);
    		case EOF:
            	return(NULL);
    		default:
    			bp[cndx++] = c;
    			break;
    	}
  	}
	bp[cndx]   = '\0';
	
    return(str);
}
//________________________________________________________________________________
int
parse_line(char *line, char *name, char *value)
{
	// Remove leading whitespace from line
	while(IS_WHITESPACE(line[0])) {
		line++;
	}
	// Skip line if it's a comment, or empty
	if(line[0] == '#' || line[0] == '\0') {
		return(0);
	}
	// Remove trailing whitespace from line
	size_t count = strlen(line)-1;
	while(IS_WHITESPACE(line[count])) {
		line[count--] = '\0';
	}

	char *name_ptr  = line;
	char *value_ptr = line;
	
	// If there are any whitespace characters remaining in the string treat
	// them as name/value seperators, replace the first one with nil to
	// terminate the string pointed to by name, also offset value to the
	// first non-whitespace character after the whitespace which should be
	// the beginning of the value.
	while(!IS_WHITESPACE(value_ptr[0]) && (value_ptr[0] != '\0') ) {
		value_ptr++;
	}
	if(value_ptr[0] != '\0') {
		value_ptr[0] = '\0';
		value_ptr++;
		
		while(IS_WHITESPACE(value_ptr[0])) {
			value_ptr++;
		}
	}
	
	strcpy(name,  name_ptr);
	strcpy(value, value_ptr);
	
	return( strlen(value) );
}
//________________________________________________________________________________
//________________________________________________________________________________
void
parse_kboot(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec)
{
	FILE			*io_file;

	io_file = fopen(io_filename, "r");
	if (io_file) {
		char			line_str[256];
			
		while ( freadline(line_str, 80, io_file) ) {
		}
	
		fclose(io_file);
	}
}
//________________________________________________________________________________
//________________________________________________________________________________
void
parse_grub(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec)
{
	// example grub entry (under Ubuntu)
	//
	// title		Ubuntu 7.10, kernel 2.6.22-14-generic
	// root			(hd0,0)
	// kernel		/boot/vmlinuz-2.6.22-14-generic root=UUID=494c191e-f6df-45b2-9928-2a7345b372f5 ro quiet splash
	// initrd		/boot/initrd.img-2.6.22-14-generic
	// quiet

	int			kexec_entries;
	int			kexec_default;
	KEXEC_ENTRY		kexec[20];
	//
	FILE			*io_file;
	char			name[256], value[256];

	kexec_entries =-1;
	kexec_default =-1;
	
	io_file = fopen(io_filename, "r");
	if (io_file) {
		char		line_str[256];
			
		while ( freadline(line_str, 256, io_file) ) {
			if (0) {
				fprintf(stdout, "%s\n", line_str);
			}
			if ( parse_line(line_str, name, value) ) {
				if ( strcasestr(name, "default") ) {
					// there should be only one default entry
					sscanf(value, "%d", &kexec_default);
					//
				} else if ( strcasestr(name, "title") ) {
					// there should be a title for all entries so
					// use it to drive the index counter.
					if ( strlen(value) ) {
						if (kexec_entries < 19) {
							kexec_entries++;
						} else {
							break;
						}
					}
					strcpy(kexec[kexec_entries].title, value);
					strcpy(kexec[kexec_entries].kernel, "");
					strcpy(kexec[kexec_entries].initrd, "");
					strcpy(kexec[kexec_entries].cmdline, "");
					//
				} else if ( strcasestr(name, "kernel") ) {
					char			*cmdline;
					
					cmdline = value;
					while(!IS_WHITESPACE(cmdline[0]) && (cmdline[0] != '\0') ) {
						cmdline++;
					}
					// this will terminate the kernel path token
					if(cmdline[0] != '\0') {
						cmdline[0] = '\0';
						cmdline++;
						// the rest is either the command-line token or end of string
						strcpy(kexec[kexec_entries].cmdline, cmdline);
					}
					// append root path to this filesystem
					strcpy(kexec[kexec_entries].kernel, io_root);
					if ( value[0] != '/' ) {
						strcat(kexec[kexec_entries].kernel, "/");
					}
					strcat(kexec[kexec_entries].kernel, value);
					//
				} else if ( strcasestr(name, "initrd") ) {
					// append root path to this filesystem
					strcpy(kexec[kexec_entries].initrd, io_root);
					if ( value[0] != '/' ) {
						strcat(kexec[kexec_entries].initrd, "/");
					}
					strcat(kexec[kexec_entries].initrd, value);
				}
			}
		}
		// done with the config file
		fclose(io_file);
		
		if ( (kexec_entries > -1) && (kexec_default > -1) ) {
			strcpy(io_kexec->title,   kexec[ kexec_default ].title);
			strcpy(io_kexec->kernel,  kexec[ kexec_default ].kernel);
			strcpy(io_kexec->initrd,  kexec[ kexec_default ].initrd);
			strcpy(io_kexec->cmdline, kexec[ kexec_default ].cmdline);
		}
	}
}
//________________________________________________________________________________
//________________________________________________________________________________
void
parse_syslinux(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec)
{
	// example syslinux/isolinux entry (under Ubuntu)
	//
	//	prompt 1
	//	display boot.msg
	//		
	//	default linux
	//	label linux
	//	  kernel vmlinuz
	//	  append initrd=initrd0.img boot=usb

	int			kexec_entries;
	char			kexec_default_label[256];
	KEXEC_ENTRY		kexec[10];
	//
	FILE			*io_file;
	char			name[256], value[256];

	kexec_entries =-1;
	strcpy(kexec_default_label, "");
	
	io_file = fopen(io_filename, "r");
	if (io_file) {
		char		line_str[256];
			
		while ( freadline(line_str, 256, io_file) ) {
			if ( parse_line(line_str, name, value) ) {
				if ( strcasestr(name, "default") ) {
					// there should be only one default entry
					strcpy(kexec_default_label, value);
					//
				} else if ( strcasestr(name, "label") ) {
					// there should be a label for all entries so
					// use it to drive the index counter.
					if ( strlen(value) ) {
						if (kexec_entries < 9) {
							kexec_entries++;
						} else {
							break;
						}
					}
					strcpy(kexec[kexec_entries].title, value);
					strcpy(kexec[kexec_entries].kernel, "");
					strcpy(kexec[kexec_entries].initrd, "");
					strcpy(kexec[kexec_entries].cmdline, "");
					//
				} else if ( strcasestr(name, "kernel") ) {
					// append root path to this kernel
					strcpy(kexec[kexec_entries].kernel, io_root);
					if ( value[0] != '/' ) {
						strcat(kexec[kexec_entries].kernel, "/");
					}
					strcat(kexec[kexec_entries].kernel, value);
					//
				} else if ( strcasestr(name, "append") ) {
					char			*initrd_ptr;
					
					// the append token is the command-line param
					strcpy(kexec[kexec_entries].cmdline, value);

					// we have to extract any "initrd=xxxx" token for kexec
					initrd_ptr = strstr(value, "initrd=");
					if (initrd_ptr) {
						char			initrd[256];
						
						strcpy(initrd, initrd_ptr);
						// convert the "=" into a space
						initrd[6] = ' ';
						if ( parse_line(initrd, name, value) ) {
							initrd_ptr = value;
							while(!IS_WHITESPACE(initrd_ptr[0]) && (initrd_ptr[0] != '\0') ) {
								initrd_ptr++;
							}
							// this will terminate the kernel path token
							if(initrd_ptr[0] != '\0') {
								initrd_ptr[0] = '\0';
							}
							// append root path to this initrd
							strcpy(kexec[kexec_entries].initrd, io_root);
							if ( value[0] != '/' ) {
								strcat(kexec[kexec_entries].initrd, "/");
							}
							strcat(kexec[kexec_entries].initrd, value);
						}
					}
				}
			}
		}
		// done with the config file
		fclose(io_file);
		
		if (kexec_entries > -1) {
			int				kexec_default;
			
			// kexec_entries is one less because we started at -1 so correct it now
			kexec_entries++;
			
			for (kexec_default = 0; kexec_default < kexec_entries; kexec_default++) {
				if ( strstr(kexec_default_label, kexec[ kexec_default ].title) ) {
					// found it
					break;
				}
			}
			// if we did not find the default label, just pick the first entry
			if (kexec_default > kexec_entries) {
				kexec_default = 0;
			}
			//
			strcpy(io_kexec->title,   kexec[ kexec_default ].title);
			strcpy(io_kexec->kernel,  kexec[ kexec_default ].kernel);
			strcpy(io_kexec->initrd,  kexec[ kexec_default ].initrd);
			strcpy(io_kexec->cmdline, kexec[ kexec_default ].cmdline);
		}
	}
}
//________________________________________________________________________________
//________________________________________________________________________________
void
parse_mb_boot_tv(char *io_root, char *io_filename, KEXEC_ENTRY *io_kexec)
{
	// example mb_boot_tv entry (under Ubuntu)
	//
	// #try-net-boot
	// kernel /vmlinuz
	// append ro root=/dev/sda5 irqpoll
	// initrd /initrd.gz
	
	int				kexec_entries;
	int				kexec_default;
	KEXEC_ENTRY		kexec[10];
	//
	FILE			*io_file;
	char			name[256], value[256];

	kexec_entries = 0;
	kexec_default = 0;
	//
	io_file = fopen(io_filename, "r");
	if (io_file) {
		char		line_str[256];
			
		while ( freadline(line_str, 256, io_file) ) {
			if ( parse_line(line_str, name, value) ) {
				if ( strcasestr(name, "kernel") ) {
					// append root path to this kernel
					strcpy(kexec[kexec_entries].kernel, io_root);
					if ( value[0] != '/' ) {
						strcat(kexec[kexec_entries].kernel, "/");
					}
					strcat(kexec[kexec_entries].kernel, value);
					//
				} else if ( strcasestr(name, "append") ) {
					// the append token is the command-line params
					strcpy(kexec[kexec_entries].cmdline, value);
					//
				} else if ( strcasestr(name, "initrd") ) {
					// append root path to this initrd
					strcpy(kexec[kexec_entries].initrd, io_root);
					if ( value[0] != '/' ) {
						strcat(kexec[kexec_entries].initrd, "/");
					}
					strcat(kexec[kexec_entries].initrd, value);
				}
			}
		}
		// done with the config file
		fclose(io_file);
		
		if (kexec_entries > -1) {
			strcpy(io_kexec->title, "");
			strcpy(io_kexec->kernel,  kexec[ kexec_default ].kernel);
			strcpy(io_kexec->initrd,  kexec[ kexec_default ].initrd);
			strcpy(io_kexec->cmdline, kexec[ kexec_default ].cmdline);
		}
	}
}


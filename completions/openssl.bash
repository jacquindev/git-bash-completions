# Source:
# - https://github.com/GArik/bash-completion/blob/master/completions/openssl

# bash completion for openssl                              -*- shell-script -*-

_openssl_sections() {
    local config f

    # check if a specific configuration file is used
    for ((i = 2; i < cword; i++)); do
        if [[ "${words[i]}" == -config ]]; then
            config=${words[i + 1]}
            break
        fi
    done

    # if no config given, check some usual default locations
    if [[ -z $config ]]; then
        for f in /etc/ssl/openssl.cnf /etc/pki/tls/openssl.cnf /usr/share/ssl/openssl.cnf; do
            [[ -f $f ]] && config=$f && break
        done
    fi

    [[ ! -f $config ]] && return 0

    COMPREPLY=($(compgen -W "$(awk '/\[.*\]/ {print $2}' "$config")" -- "$cur"))
}

_openssl() {
    local cur prev words cword
    _init_completion || return

    local commands command options formats

    commands='asn1parse ca ciphers crl crl2pkcs7 dgst dh dhparam dsa dsaparam
        ec ecparam enc engine errstr gendh gendsa genrsa nseq ocsp passwd
        pkcs12 pkcs7 pkcs8 prime rand req rsa rsautl s_client s_server s_time
        sess_id smime speed spkac verify version x509 md2 md4 md5 rmd160 sha
        sha1 aes-128-cbc aes-128-ecb aes-192-cbc aes-192-ecb aes-256-cbc
        aes-256-ecb base64 bf bf-cbc bf-cfb bf-ecb bf-ofb camellia-128-cbc
        camellia-128-ecb camellia-192-cbc camellia-192-ecb camellia-256-cbc
        camellia-256-ecb cast cast-cbc cast5-cbc cast5-cfb cast5-ecb cast5-ofb
        des des-cbc des-cfb des-ecb des-ede des-ede-cbc des-ede-cfb des-ede-ofb
        des-ede3 des-ede3-cbc des-ede3-cfb des-ede3-ofb des-ofb des3 desx rc2
        rc2-40-cbc rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb rc4 rc4-40'

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    else
        command=${words[1]}
        case $prev in
        -CA | -CAfile | -CAkey | -CAserial | -cert | -certfile | -config | -content | \
            -dcert | -dkey | -dhparam | -extfile | -in | -inkey | -kfile | -key | -keyout | \
            -out | -oid | -prvrify | -rand | -recip | -revoke | -sess_in | -sess_out | \
            -spkac | -sign | -signkey | -signer | -signature | -ss_cert | -untrusted | \
            -verify)
            _filedir
            return 0
            ;;
        -outdir | -CApath)
            _filedir -d
            return 0
            ;;
        -name | -crlexts | -extensions)
            _openssl_sections
            return 0
            ;;
        -inform | -outform | -keyform | -certform | -CAform | -CAkeyform | -dkeyform | -dcertform)
            formats='DER PEM'
            case $command in
            x509)
                formats+=" NET"
                ;;
            smime)
                formats+=" SMIME"
                ;;
            esac
            COMPREPLY=($(compgen -W "$formats" -- "$cur"))
            return 0
            ;;
        -connect)
            _known_hosts_real "$cur"
            return 0
            ;;
        -starttls)
            COMPREPLY=($(compgen -W 'smtp pop3 imap ftp' -- "$cur"))
            return 0
            ;;
        -cipher)
            COMPREPLY=($(IFS=: compgen -W "$(openssl ciphers)" -- "$cur"))
            return 0
            ;;
        esac

        if [[ "$cur" == -* ]]; then
            # possible options for the command
            case $command in
            asn1parse)
                options='-inform -in -out -noout -offset -length -i -oid
                        -strparse'
                ;;
            ca)
                options='-verbose -config -name -gencrl -revoke -crl_reason
                        -crl_hold -crl_compromise -crl_CA_compromise -crldays
                        -crlhours -crlexts -startdate -enddate -days -md
                        -policy -keyfile -key -passin -cert -selfsig -in -out
                        -notext -outdir -infiles -spkac -ss_cert -preserveDN
                        -noemailDN -batch -msie_hack -extensions -extfile
                        -engine -subj -utf8 -multivalue-rdn'
                ;;
            ciphers)
                options='-v -ssl2 -ssl3 -tls1'
                ;;
            crl)
                options='-inform -outform -text -in -out -noout -hash
                        -issuer -lastupdate -nextupdate -CAfile -CApath'
                ;;
            crl2pkcs7)
                options='-inform -outform -in -out -print_certs'
                ;;
            dgst)
                options='-md5 -md4 -md2 -sha1 -sha -mdc2 -ripemd160 -dss1
                        -c -d -hex -binary -out -sign -verify -prverify
                        -signature'
                ;;
            dsa)
                options='-inform -outform -in -passin -out -passout -des
                        -des3 -idea -text -noout -modulus -pubin -pubout'
                ;;
            dsaparam)
                options='-inform -outform -in -out -noout -text -C -rand
                        -genkey'
                ;;
            enc)
                options='-ciphername -in -out -pass -e -d -a -A -k -kfile
                        -S -K -iv -p -P -bufsize -debug'
                ;;
            dhparam)
                options='-inform -outform -in -out -dsaparam -noout -text
                        -C -2 -5 -rand'
                ;;
            gendsa)
                options='-out -des -des3 -idea -rand'
                ;;
            genrsa)
                options='-out -passout -des -des3 -idea -f4 -3 -rand'
                ;;
            pkcs7)
                options='-inform -outform -in -out -print_certs -text
                        -noout'
                ;;
            rand)
                options='-out -rand -base64'
                ;;
            req)
                options='-inform -outform -in -passin -out -passout -text
                        -noout -verify -modulus -new -rand -newkey -newkey
                        -nodes -key -keyform -keyout -md5 -sha1 -md2 -mdc2
                        -config -x509 -days -asn1-kludge -newhdr -extensions
                        -reqexts section'
                ;;
            rsa)
                options='-inform -outform -in -passin -out -passout
                        -sgckey -des -des3 -idea -text -noout -modulus -check
                        -pubin -pubout -engine'
                ;;
            rsautl)
                options='-in -out -inkey -pubin -certin -sign -verify
                        -encrypt -decrypt -pkcs -ssl -raw -hexdump -asn1parse'
                ;;
            s_client)
                options='-connect -verify -cert -certform -key -keyform
                        -pass -CApath -CAfile -reconnect -pause -showcerts
                        -debug -msg -nbio_test -state -nbio -crlf -ign_eof
                        -quiet -ssl2 -ssl3 -tls1 -no_ssl2 -no_ssl3 -no_tls1
                        -bugs -cipher -starttls -engine -tlsextdebug
                        -no_ticket -sess_out -sess_in -rand'
                ;;
            s_server)
                options='-accept -context -verify -Verify -crl_check
                        -crl_check_all -cert -certform -key -keyform -pass
                        -dcert -dcertform -dkey -dkeyform -dpass -dhparam
                        -nbio -nbio_test -crlf -debug -msg -state -CApath
                        -CAfile -nocert -cipher -quiet -no_tmp_rsa -ssl2
                        -ssl3 -tls1 -no_ssl2 -no_ssl3 -no_tls1 -no_dhe
                        -bugs -hack -www -WWW -HTTP -engine -tlsextdebug
                        -no_ticket -id_prefix -rand'
                ;;
            s_time)
                options='-connect -www -cert -key -CApath -CAfile -reuse
                        -new -verify -nbio -time -ssl2 -ssl3 -bugs -cipher'
                ;;
            sess_id)
                options='-inform -outform -in -out -text -noout -context ID'
                ;;
            smime)
                options='-encrypt -decrypt -sign -verify -pk7out -des -des3
                        -rc2-40 -rc2-64 -rc2-128 -aes128 -aes192 -aes256 -in
                        -certfile -signer -recip -inform -passin -inkey -out
                        -outform -content -to -from -subject -text -rand'
                ;;
            speed)
                options='-engine'
                ;;
            verify)
                options='-CApath -CAfile -purpose -untrusted -help
                        -issuer_checks -verbose -certificates'
                ;;
            x509)
                options='-inform -outform -keyform -CAform -CAkeyform -in
                        -out -serial -hash -subject_hash -issuer_hash -subject
                        -issuer -nameopt -email -startdate -enddate -purpose
                        -dates -modulus -fingerprint -alias -noout -trustout
                        -clrtrust -clrreject -addtrust -addreject -setalias
                        -days -set_serial -signkey -x509toreq -req -CA -CAkey
                        -CAcreateserial -CAserial -text -C -md2 -md5 -sha1
                        -mdc2 -clrext -extfile -extensions -engine'
                ;;
            md5 | md4 | md2 | sha1 | sha | mdc2 | ripemd160)
                options='-c -d'
                ;;
            esac
            COMPREPLY=($(compgen -W "$options" -- "$cur"))
        else
            if [[ "$command" == speed ]]; then
                COMPREPLY=($(compgen -W 'md2 mdc2 md5 hmac sha1 rmd160
                    idea-cbc rc2-cbc rc5-cbc bf-cbc des-cbc des-ede3 rc4
                    rsa512 rsa1024 rsa2048 rsa4096 dsa512 dsa1024 dsa2048 idea
                    rc2 des rsa blowfish' -- "$cur"))
            else
                _filedir
            fi
        fi
    fi
}

complete -F _openssl -o default openssl openssl.exe

# ex: ts=4 sw=4 et filetype=sh

#!/bin/bash
# my alteration of https://github.com/mossberg/dotfiles to work for my config on linux and osx

DOTFILES_ROOT="`pwd`"
UNAME=$(uname -s)
# get inverse of uname so we don't install those files
if [ ${UNAME} == "Linux" ]; then
    NOT_UNAME="Darwin"
else
    NOT_UNAME="Linux"
fi

. functions.sh

link_generic_fish() {
    # remove all symlinks in Darwin and Linux
    find "$DOTFILES_ROOT/Darwin" "$DOTFILES_ROOT/Linux" -type l -delete

    # general functions
    for source in `find $DOTFILES_ROOT/fish/functions/*.fish`; do
        link_file $source "$DOTFILES_ROOT/Darwin/fish/config.symlink/fish/functions/`basename $source`"
        link_file $source "$DOTFILES_ROOT/Linux/fish/config.symlink/fish/functions/`basename $source`"
    done

    # general config
    for item in $(find $DOTFILES_ROOT/fish/*.fish); do
        link_file $item "$DOTFILES_ROOT/Darwin/fish/config.symlink/fish/$(basename $item)"
        link_file $item "$DOTFILES_ROOT/Linux/fish/config.symlink/fish/$(basename $item)"
    done
}

install_dotfiles() {
    echo ""
    info "installing dotfiles"

    overwrite_all=false
    backup_all=false
    skip_all=false

    for source in `find $DOTFILES_ROOT -name \*.symlink -not -path "$DOTFILES_ROOT/$NOT_UNAME/*"`; do
        if [ "$skip_all" == "true" ]; then
            success "skipped $source"
            continue
        fi

        dest="$HOME/.`basename \"${source%.*}\"`"

        if [ `basename $dest` == ".config" ]; then
            item_name=`ls $source | head -1`
            source="$source/$item_name"
            dest="$dest/$item_name"

            user "Changed source to $source and dest to $dest - continue (y/n)?"
            read -p "" action
            case "$action" in
                y|Y)
                    ;;
                n|N )
                    continue;;
                *)
                    info "invalid - skipping"
                    continue
                    ;;
            esac
        fi

        if [ -f $dest ] || [ -d $dest ]; then
            overwrite=false
            backup=false
            skip=false

            if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
                user "File already exists: `basename $source`, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
                read -p "" action

                case "$action" in
                    o )
                        overwrite=true;;
                    O )
                        overwrite_all=true;;
                    b )
                        backup=true;;
                    B )
                        backup_all=true;;
                    s )
                        skip=true;;
                    S )
                        skip_all=true;;
                    * )
                        ;;
                esac
            fi


            if [ "$overwrite" == "true" ] || [ "$overwrite_all" == "true" ]; then
                rm -rf $dest
                success "removed $dest"
            fi

            if [ "$backup" == "true" ] || [ "$backup_all" == "true" ]; then
                mv $dest $dest\.backup
                success "moved $dest to $dest.backup"
            fi

            if [ "$skip" == "false" ] && [ "$skip_all" == "false" ]; then
                link_file $source $dest
            else
                success "skipped $source"
            fi
        else
            link_file $source $dest
        fi

    done

    info "done with dotfiles"
}

run_install_scripts() {
    echo ""
    info "running install scripts"

    for install_script in `find $DOTFILES_ROOT -name install.sh -not -path $DOTFILES_ROOT/install.sh`; do
        local_path="$(basename $(dirname ${install_script}))/$(basename ${install_script})"

        if [ ${local_path} == "Linux*" ] && [ $(uname -s) != "Linux" ]; then
            continue
        fi

        info "running ${local_path}"
        $install_script
        if [ ! $? -eq 0 ]; then
            fail "$install_script failed"
        else
            info "${local_path} finished"
        fi
    done

    info "done with install scripts"
}

link_bin_files() {
    BIN="$DOTFILES_ROOT/bin"
    if [ -d "$BIN" ]; then
        echo ""
        info "linking bin files"
        for bin in `find $BIN -type f`; do
            link_file $bin "/usr/local/bin/`basename $bin`" --root
        done
    fi
}

# do things!
link_generic_fish
install_dotfiles
run_install_scripts
link_bin_files

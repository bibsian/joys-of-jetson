#!/bin/bash
source utils.sh

set -e # Will exit if anything fails

usage="program: $(basename "$0")
required args: <[-e]>
Program to install and configure Jupyter Notebooks within a 
virtual environment on the Jetson Nano.

Defaults to python3 and assumes VIRTUALENV_WRAPPER path set
to /usr/bin/python3.

Where arguments REQUIRED are:
    -e  Name of virutal environment to install Jupyter dependencies
"
while getopts ':e:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    e) VENV=$OPTARG       
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "$VENV" ]
then
   echo "****************************************"
   echo "**** Missing required argument [-e] ****"
   echo "****************************************"
   echo "$usage"
   exit
fi

VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 
source /usr/local/bin/virtualenvwrapper.sh

workon $VENV && echo "Working on $VENV virtual environment"

echo 'Installing dependencies for matplotlib & json parsing in bash'
sudo apt update \
&& sudo apt install -y libfreetype6-dev pkg-config libpng-dev jq

echo 'Pip installing jupyter, matplotlib, ipython kernal'
echo "which pip3 == $(which pip3)"
pip3 install jupyter matplotlib ipykernel

jupyter notebook --generate-config
jupyter notebook password
chown $USER:$USER $HOME/.jupyter #change ownership

makeCerts

JUPYTER_CONFIG_FILE="$HOME/.jupyter/jupyter_notebook_config.py"
JUPYTER_PWD=$(sudo jq '.NotebookApp.password' $HOME/.jupyter/jupyter_notebook_config.json)

JUPYTER_CONFIG_UPDATE=\
"c = get_config()

# Kernel config
c.IPKernelApp.pylab = 'inline'  # if you want plotting support always in your notebook

# Notebook config
c.NotebookApp.certfile = u'$HOME/certs/mycert.pem' #location of your certificate file
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.open_browser = False  #so that the ipython notebook does not opens up a browser by default
c.NotebookApp.password = u$JUPYTER_PWD  #the encrypted password we generated above
# Set the port to 8888, the port we set up in the AWS EC2 set-up
c.NotebookApp.port = 8889

# Configuration file for jupyter-notebook.
c.Notebook.allow_origin='*'

c.InteractiveShellApp.extensions = ['autoreload']
c.InteractiveShellApp.exec_lines = ['%autoreload 2']
"
sudo printf '%s\n%s\n' "$JUPYTER_CONFIG_UPDATE" "$(sudo cat $JUPYTER_CONFIG_FILE)" > $JUPYTER_CONFIG_FILE

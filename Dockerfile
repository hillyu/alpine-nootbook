ARG base="hillyu/alpine-scipy-base:latest" 
FROM ${base}
ARG USE_MIRROR
ARG alpine_packages="graphviz py3-matplotlib"
ARG alpine_deps="make automake g++ linux-headers"
ARG python_packages="ipywidgets notebook seaborn"

RUN echo "|--> Updating" \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||echo "$USE_MIRROR";
RUN echo "|--> Install Alpine-supported packages (from edge repo)" \
    && apk update && apk upgrade \
    && apk add --no-cache ${alpine_packages}\
    && ln -s locale.h /usr/include/xlocale.h \
    && echo "|--> Install build dependencies(to-be-removed later)" \
    && apk add --no-cache --virtual=.build-deps \
        ${alpine_deps}\
    && echo "|--> Install Python packages"; 
RUN pip install -U --no-cache-dir ${python_packages} \
        $([ "$USE_MIRROR" = "true" ] && echo "-i https://pypi.douban.com/simple" ||:)\
    && echo "|--> Cleaning" \
    && rm /usr/include/xlocale.h \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    && rm -rf /var/cache/apk/* \
    && find /usr/lib/ -name __pycache__ | xargs rm -r \
    && apk del .build-deps \
    && echo "|--> Configure Jupyter extension" \
    && jupyter nbextension enable --py widgetsnbextension \
    && mkdir -p ~/.ipython/profile_default/startup/ \
    && echo "import warnings" >> ~/.ipython/profile_default/startup/config.py \
    && echo "warnings.filterwarnings('ignore')" >> ~/.ipython/profile_default/startup/config.py \
    && echo "c.NotebookApp.token = u''" >> ~/.ipython/profile_default/startup/config.py \
    && echo "|--> Done!"
#ENTRYPOINT ["/sbin/tini", "--"]

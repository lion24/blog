FROM jekyll/jekyll:4 as builder
ENV JEKYLL_ENV production
# Seems that we have to redifine HOME var, strange...
COPY --chown=jekyll:jekyll . .
ENV HOME /home/jekyll
ENV GEM_HOME ${HOME}/.gem
ENV PATH ${GEM_HOME}/bin:${PATH}
RUN ./script/bootstrap
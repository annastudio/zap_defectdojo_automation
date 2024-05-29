FROM --platform=linux/amd64 softwaresecurityproject/zap-stable
#FROM softwaresecurityproject/zap-stable

USER root

# Install and update all add-ons
RUN ./zap.sh -cmd -silent -addoninstallall
RUN ./zap.sh -cmd -silent -addonupdate
RUN cp /root/.ZAP/plugin/*.zap plugin/ || :

RUN mkdir /zap/wrk

ADD . /zap/
RUN cd /home/zap/ && echo $(ls)

RUN chown zap:zap /zap/zap-baseline-custom.py && \
	chmod +x /zap/zap-baseline-custom.py
	
RUN chown zap:zap /zap/zap-api-scan_custom.py && \
	chmod +x /zap/zap-api-scan_custom.py	

RUN chown zap:zap /zap/zap-full-scan-custom.py && \
	chmod +x /zap/zap-full-scan-custom.py

RUN chown zap:zap /zap/zap_common_custom.py 

#RUN chown zap:zap /zap/ZAPonEventHandler.py && \
#        chmod +x /zap/ZAPonEventHandler.py

USER zap

VOLUME /zap/wrk
WORKDIR /zap

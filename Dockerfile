FROM btdi/btd
COPY btd/ /btd
RUN pip install -r /btd/requirements.txt
ENTRYPOINT ["/btd/cli.py", "run"]

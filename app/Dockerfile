FROM public.ecr.aws/lambda/nodejs:16

COPY hello.js ${LAMBDA_TASK_ROOT}

RUN chmod 644 $(find . -type f)

CMD [ "hello.handler" ]  
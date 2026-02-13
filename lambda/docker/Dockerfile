FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY lambda_handler.py "${LAMBDA_TASK_ROOT}/lambda_handler.py"

CMD ["lambda_handler.handler"]

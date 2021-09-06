# Регистр счетов в банке

### Описание приложения:

- Создать систему учета банковских счетов пользователей.

### Функциональность:
- Создание пользователя с указанием тегов.
Для создания пользователя нужно заполнить поля: ФИО,
идентификационный номер, теги.
Ограничения: нельзя создать двух пользователей с одинаковым
идентификационным номером.
- Открытие счета для пользователя по идентификационному номеру
пользователя. Для открытия счета нужно заполнить поля: валюта (по стандарту ISO
4217), идентификационный номер пользователя. После открытия счета
система указывает уникальный номер нового счета.
Ограничения: пользователь не может создать два счета с одной и той же
валютой, сумма должна быть неотрицательной.
- Пополнение счета по идентификационному номеру пользователя и
валюте на определенную сумму. Если у получателя нет счета в данной
валюте, необходимо создать и провести операцию.
- Перевод между счетами по идентификационному номеру пользователяотправителя, валюте и идентификационному номеру получателя. Если у
  получателя нет счета в данной валюте, необходимо создать и провести
  операцию.
- Отчет "О сумме пополнений за период времени по-валютно" с
  возможностью фильтрации по пользователям.
- Отчет "Средняя, максимальная и минимальная сумма переводов по
  тегам пользователей за период времени" с возможностью фильтрации
  по тегам.
- Отчет "Сумма всех счетов на текущий момент времени повалютно" с
  фильтрацией по тегам пользователей.

### Примечания:
- Сериалазеры не добавлены. В рамках текущей реализации нет необходимости.
- При выводе отчета "Средняя, максимальная и минимальная сумма переводов по
  тегам пользователей за период времени" фильтрация по тегам происходит по пользователям, выполнившим перевод.
- При выводе отчета "Сумма всех счетов на текущий момент времени повалютно", достаем все записи - если таблица достаточно большая могут возникнуть проблемы, возможное решение доставать частями(закоментировано).

### Инструкция:

Создать базу данных, сгенерить сиды, запустить сервер:
- rails db:create
- rails db:migrate
- rails db:seed
- rails s

Существуют следующие ендпоинты(format :json):
- POST api/v1/users
```shell
 curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"first_name":"curl","last_name":"curl","identity_number":"curl","tags":["c","u"]}' \
  http://localhost:3000/api/v1/users
```

- POST api/v1/accounts/create
```shell
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"currency":"USD","identity_number":"curl"}' \
  http://localhost:3000/api/v1/accounts/create
```

- POST api/v1/accounts/deposit
```shell
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"currency":"USD","identity_number":"curl", "amount": 100}' \
  http://localhost:3000/api/v1/accounts/deposit
```

- POST api/v1/accounts/transfer
```shell
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"currency":"USD","identity_number_producer":"curl1", "identity_number_producer":"curl2", "amount": 100}' \
  http://localhost:3000/api/v1/accounts/transfer
```

- POST api/v1/reports/sum_deposit_by_currencies
```shell
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"from":"2021-08-30","to":"2021-09-06","user_id": "1"}' \
  http://localhost:3000/api/v1/reports/sum_deposit_by_currencies
```

- POST api/v1/reports/average_max_min_transfer
```shell
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"from":"2021-08-30","to":"2021-09-06","tags": ["t"]}' \
  http://localhost:3000/api/v1/reports/average_max_min_transfer
```

- POST api/v1/reports/sum_account_balance_by_currencies
```shell
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"tags": ["t"]}' \
  http://localhost:3000/api/v1/reports/sum_account_balance_by_currencies
```

# Spellchecker

Маленькое Rack-приложение, чтобы исправлять _твои_ опечатки.


## Что

Отправляешь POST-запрос с запросом, содержащим ошибки:

```json
{"result": "плптье женская"}
```

Получаешь в ответ JSON с исправлением:

```json
{"result": "платье женская"}
```


## Как

Под капотом используется [Hunspell]:

 1. Rack-приложение принимает JSON, достаёт из него строку
 2. Каждое слово из строки скармливается libhunspell.so на проверку
 3. Для непрошедших слов ищутся варианты замены там же
 4. Строка собирается обратно из (возможно) исправленных слов и отдаётся клиенту


## Запуск

### Через Docker

 1. Соберите образ:

        docker build -t spellchecker .

 2. Запустите контейнер:

        docker run -it --rm -p 5000:5000 spellchecker

 3. Проверьте работу:

        curl -f -X POST -d '{"query": "Плптье женское"}' http://localhost:5000/


### Вручную

Потребуется последняя версия [JRuby] (9.1 или новее).

> MRI не рекомендуется использовать при запуске через потоковые веб-серверы,
> например Puma — из-за GIL приложение будет де-факто выполняться в один поток.

 1. Установите [Hunspell]:

    ```sh
    sudo apt install hunspell # Linux (Debian)
    brew install hunspell     # OS X
    ```

 2. Скачайте русский словарь:

    ```sh
    export DEST=/usr/share/hunspell # Linux (Debian)
    export DEST=~/Library/Spelling  # OS X
    curl 'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/ru_RU/ru_RU.{dic,aff}' -o "$DEST/ru_RU.#1"
    ```

 3. Установите зависимости:

        bundle install

 4. Запустите сервис:

    ```sh
    rackup -s puma -p ${PORT:-5000} -o 0.0.0.0 -O "Threads=0:${MAX_THREADS:-16}"
    ```

 5. Проверьте работу:

        curl -f -X POST -d '{"query": "Плптье женское"}' http://localhost:5000/


## Тестирование

    rspec


## Конфигурация

Учитываются следующие переменные окружения:

 - `DICTIONARY_FILE` — полный путь к файлу с дополнительным словарём (словарь должен быть в той же кодировке и использовать те же сигнатуры аффиксов, что и словарь `ru_RU` из вашего Hunspell). По умолчанию используется [custom.dic](./custom.dic).


[Hunspell]: http://hunspell.github.io/
[JRuby]: http://jruby.org/ (The Ruby Programming Language on the JVM)
[Rack]: https://rack.github.io/ (Rack: a Ruby Webserver Interface)
[Puma]: http://puma.io/ (A modern, concurrent web server for Ruby)
[Docker]: https://www.docker.com/ (Docker is the world’s leading software containerization platform)

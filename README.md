# oracle-php7

### Como usar

```
# Dockerfile
FROM semgeba/oracle-php7
RUN composer update
CMD php artisan serve --host 0.0.0.0 --port $PORT --env=$ENV # se estiver usando laravel
CMD php -S 0.0.0.0:8000 # se estiver usando o servidor embutido do PHP
```

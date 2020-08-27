# ReKoast
Сборка сервера для Just Cause 2: Multiplayer Mod

Инструкция по созданию сервера:
1. Удалите папку 'scripts' ( Если имеется ) (( default_scripts ничего не делает, удалять не обязательно ))
2. В конфиге сервера включите IKnowWhatImDoing, чтобы избавиться от большинства ошибок.
3. Перекиньте скаченную папку scripts в корневую папку сервера.
4. Запускайте сервер.

Как выдать роль?
1. Перейдите в scripts/2-AdminSystem/server/
2. Откройте нужный .txt и добавьте свой SteamID в него.
3. Перезапустите модуль (reload 2-AdminSystem в консоль сервера).

Как изменить лого сервера?
1. Перейдите в scripts/0-ServerInfo/server/
2. Откройте servername.txt и впишите название своего сервера (Если не хотите логотип, оставьте всё пустым).

Как вписать свои правила?
1. Перейдите в scripts/22-Help/server/
2. Откройте rules.txt и впишите свои правила.

Как добавить супер ускорение и Иисус-мод?
1. Перейдите в scripts/Others/
2. Перетащите нужные модули в scripts.
Knockdown
=========

angular-like KnockoutJS

- Заменяет биндинги, вида `data-bind="N: value"` на `nd-N="value"`
- Заменяет биндинги, вида `data-bind="attr: {class: 'some'}` на `nd-attr="class: 'some'"`, т.е. фигурные скобки писать не обязательно
- Автоматически биндит все dom-элементы с атрибутом `nd-controller`, где значение атрибута является ключом `KEY` в js выражении `nd.controller('KEY', function(){});`
- Доступные биндинги
```
nd-component 
nd-attr 
nd-checked 
nd-checkedValue 
nd-css 
nd-enable 
nd-disable 
nd-event 
nd-foreach 
nd-hasfocus 
nd-hasFocus 
nd-html 
nd-if 
nd-ifnot 
nd-with 
nd-options 
nd-selectedOptions 
nd-style 
nd-submit 
nd-text 
nd-textInput 
nd-textinput 
nd-uniqueName 
nd-value 
nd-visible 
nd-click 
nd-template
```
- С помощью выражения `this.get(KEY)` в контроллере можно получить значение из контейнера
- С помощью атрибута `nd-node="some"` можно добавить dom-элемент в контейнер `this.get('node').some`


#### Пример шаблона:
```html
<body>
    <section class="api-example" nd-controller="highlight">
        <aside nd-foreach="nav">
            <a href="javascript:void(0)" nd-click="focus" nd-attr="class: (active()?'active':'')">
                <label class="api-get" nd-attr="class: 'api-' + type" nd-text="type">&nbsp;</label>
                <span nd-text="title"></span>
            </a>
        </aside>
        <article>
            <header>
                <section class="select" nd-click="language.toggle" 
                    nd-attr="class: 'select ' + (language.focus()?'focus':'')">
                    
                    <div class="select-current" nd-text="language.current().value">current</div>
                    <div class="select-dropdown" nd-foreach="language.values">
                        <a href="javascript:void(0);" nd-text="value" nd-click="focus">&nbsp;</a>
                    </div>
                </section>
            </header>
            <pre><code class="hljs"
               nd-id="code"
               nd-attr="class: 'hljs ' + language.current().id"
               nd-html="code"></code></pre>
        </article>
    </section>
</body>
```


#### Версия 1.1.0
- Убран ioc, теперь все объекты из контейнера можно получить с помощью метода this.get('key') в контроллере - с долларом в аргументах есть проблема в минифиакторах JS
- Теперь nd является объектом
- Теперь можно вручную проверять наличие nd-controller вызовом метода nd.applyBindings(DOM)
- Теперь можно вручную биндить контроллер вызовом nd.bind('key', DOM)
- Теперь для биндингов attr, event, css, style, component и template не надо указывать фигурные скобки в аргументах (nd-attr="class: some" вместо nd-attr="{class: some}")
- Добавлено свойство nd.version
- Теперь доступно содержание di контейнера извне: nd.container
- Теперь можно изменять именования биндингов: nd.attr содержит все ключи
- Теперь можно получить конкретный dom элемент с помощью выражения this.get('node').KEY, где KEY является значением nd-node (например: <canvas nd-node="KEY"></canvas>)
- Теперь dom после инициализации не содержит атрибутов nd-***, что избавляет от ошибок двойной инициализации

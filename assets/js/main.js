document.addEventListener('DOMContentLoaded', function() {
    // Находим контейнеры для каждой категории
    const containers = {
        lisp: document.getElementById('lisp-list'),
        windows: document.getElementById('windows-list'),
        excel: document.getElementById('excel-list'),
        other: document.getElementById('other-list')
    };

    // Флаги, чтобы отслеживать, есть ли контент в категории
    const hasContent = {
        lisp: false,
        windows: false,
        excel: false,
        other: false
    };

    fetch('data.json')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            // Перед добавлением карточек очищаем все контейнеры от надписи "пока нет"
            Object.values(containers).forEach(container => {
                if(container) container.innerHTML = '';
            });

            data.forEach(tool => {
                // Создаем HTML-код для карточки
                const toolCardHTML = `
                    <div class="col-md-6 col-lg-4">
                        <div class="card h-100">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title">${tool.title}</h5>
                                <p class="card-text">${tool.short_description}</p>
                                <a href="pages/details.html?id=${tool.id}" class="btn btn-primary mt-auto">Подробнее и скачать</a>
                            </div>
                        </div>
                    </div>
                `;

                // Определяем, в какой контейнер добавить карточку
                const category = tool.category || 'other'; // Если категория не указана, считаем ее "прочее"
                if (containers[category]) {
                    containers[category].insertAdjacentHTML('beforeend', toolCardHTML);
                    hasContent[category] = true; // Отмечаем, что в категории есть контент
                }
            });

            // После цикла проверяем, какие категории остались пустыми
            for (const category in hasContent) {
                if (!hasContent[category] && containers[category]) {
                    containers[category].innerHTML = '<p class="text-muted">Инструментов в этой категории пока нет.</p>';
                }
            }
        })
        .catch(error => {
            console.error('Ошибка при загрузке данных:', error);
            // Показываем ошибку в первом контейнере
            if(containers.lisp) containers.lisp.innerHTML = '<p class="text-danger">Не удалось загрузить список инструментов.</p>';
        });
});
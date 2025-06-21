document.addEventListener('DOMContentLoaded', function() {
    const params = new URLSearchParams(window.location.search);
    const toolId = params.get('id');

    // Находим все нужные элементы на странице
    const pageTitle = document.querySelector('title');
    const navbarBrand = document.getElementById('tool-navbar-brand');
    const mainHeader = document.getElementById('tool-main-header');
    const description = document.getElementById('tool-description');
    
    // ИЗМЕНЕНИЕ: Находим новые блоки для управления видимостью
    const mainContent = document.getElementById('main-content');
    const sidebar = document.getElementById('sidebar');
    const instructionsBlock = document.getElementById('instructions-block');
    const instructionsList = document.getElementById('tool-instructions');
    const downloadButton = document.getElementById('tool-download-button');

    if (!toolId) {
        mainHeader.textContent = 'Ошибка: Инструмент не указан';
        return;
    }

    fetch('../data.json')
        .then(response => response.json())
        .then(data => {
            const toolData = data.find(tool => tool.id === toolId);

            if (!toolData) {
                mainHeader.textContent = `Ошибка: Инструмент с ID "${toolId}" не найден`;
                return;
            }

            // Заполняем общие для всех категорий данные
            pageTitle.textContent = `Описание: ${toolData.title}`;
            navbarBrand.textContent = toolData.title;
            mainHeader.textContent = toolData.title;
            description.innerHTML = toolData.long_description;

            // ИЗМЕНЕНИЕ: Главная логика проверки категории
            if (toolData.category === 'other') {
                // Если это "прочее" (статья, текст)
                sidebar.style.display = 'none'; // Скрываем всю боковую панель
                instructionsBlock.style.display = 'none'; // Скрываем блок с инструкцией
                mainContent.classList.remove('col-lg-8'); // Убираем ограничение ширины основного контента
                mainContent.classList.add('col-lg-12');  // Растягиваем его на всю ширину
            } else {
                // Если это скачиваемый файл (lisp, excel, windows)
                sidebar.style.display = 'block'; // Показываем боковую панель
                instructionsBlock.style.display = 'block'; // Показываем блок с инструкцией
                mainContent.classList.remove('col-lg-12');
                mainContent.classList.add('col-lg-8');

                // Генерируем список с инструкцией
                instructionsList.innerHTML = '';
                if(toolData.instructions && toolData.instructions.length > 0) {
                    toolData.instructions.forEach(step => {
                        const li = document.createElement('li');
                        li.innerHTML = step;
                        instructionsList.appendChild(li);
                    });
                }

                // Настраиваем кнопку скачивания
                downloadButton.textContent = `Скачать ${toolData.download_file}`;
                downloadButton.href = `../downloads/${toolData.download_file}`;
                downloadButton.classList.remove('disabled');
            }
        })
        .catch(error => {
            console.error('Ошибка при загрузке или обработке данных:', error);
            mainHeader.textContent = 'Не удалось загрузить данные для этого инструмента.';
        });
});
document.addEventListener('DOMContentLoaded', function() {
    // 1. Получаем ID инструмента из URL-адреса
    const params = new URLSearchParams(window.location.search);
    const toolId = params.get('id');

    // Находим все элементы-плейсхолдеры на странице
    const navbarBrand = document.getElementById('tool-navbar-brand');
    const mainHeader = document.getElementById('tool-main-header');
    const description = document.getElementById('tool-description');
    const instructionsList = document.getElementById('tool-instructions');
    const downloadButton = document.getElementById('tool-download-button');
    const pageTitle = document.querySelector('title');

    // Если ID не найден в URL, показываем ошибку
    if (!toolId) {
        mainHeader.textContent = 'Ошибка: Инструмент не указан';
        return;
    }

    // 2. Загружаем данные из data.json
    fetch('../data.json')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            // 3. Находим нужный инструмент в массиве по его ID
            const toolData = data.find(tool => tool.id === toolId);

            // Если инструмент с таким ID не найден, показываем ошибку
            if (!toolData) {
                mainHeader.textContent = `Ошибка: Инструмент с ID "${toolId}" не найден`;
                return;
            }

            // 4. Заполняем страницу данными найденного инструмента
            pageTitle.textContent = `Описание: ${toolData.title}`;
            navbarBrand.textContent = toolData.title;
            mainHeader.textContent = toolData.title;
            description.innerHTML = toolData.long_description; // innerHTML чтобы теги вроде <code> работали

            // Генерируем список с инструкцией
            instructionsList.innerHTML = ''; // Очищаем список
            toolData.instructions.forEach(step => {
                const li = document.createElement('li');
                li.innerHTML = step;
                instructionsList.appendChild(li);
            });

            // Настраиваем кнопку скачивания
            downloadButton.textContent = `Скачать ${toolData.download_file}`;
            downloadButton.href = `../downloads/${toolData.download_file}`;
            downloadButton.classList.remove('disabled');

        })
        .catch(error => {
            console.error('Ошибка при загрузке или обработке данных:', error);
            mainHeader.textContent = 'Не удалось загрузить данные для этого инструмента.';
        });
});
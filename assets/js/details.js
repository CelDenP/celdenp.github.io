document.addEventListener('DOMContentLoaded', function() {
    const params = new URLSearchParams(window.location.search);
    const toolId = params.get('id');

    // ИЗМЕНЕНИЕ: Убрали 'navbarBrand' из списка, так как он больше не нужен
    const pageTitle = document.querySelector('title');
    const mainHeader = document.getElementById('tool-main-header');
    const description = document.getElementById('tool-description');
    
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

            // ИЗМЕНЕНИЕ: Убрали строку, заполнявшую старую шапку
            pageTitle.textContent = `Описание: ${toolData.title}`;
            mainHeader.textContent = toolData.title;
            description.innerHTML = toolData.long_description;

            if (toolData.category === 'other') {
                mainContent.classList.remove('col-lg-12');
                mainContent.classList.add('col-lg-12');
            } else {
                sidebar.style.display = 'block';
                instructionsBlock.style.display = 'block';

                mainContent.classList.remove('col-lg-12');
                mainContent.classList.add('col-lg-8');

                instructionsList.innerHTML = '';
                if(toolData.instructions && toolData.instructions.length > 0) {
                    toolData.instructions.forEach(step => {
                        const li = document.createElement('li');
                        li.innerHTML = step;
                        instructionsList.appendChild(li);
                    });
                }

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
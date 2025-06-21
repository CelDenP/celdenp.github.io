document.addEventListener('DOMContentLoaded', function() {
    const containers = {
        lisp: document.getElementById('lisp-list'),
        windows: document.getElementById('windows-list'),
        excel: document.getElementById('excel-list'),
        other: document.getElementById('other-list')
    };
    const hasContent = { lisp: false, windows: false, excel: false, other: false };

    fetch('data.json')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            // ИЗМЕНЕНИЕ: Переворачиваем массив. Теперь новые записи будут первыми.
            data.reverse();

            Object.values(containers).forEach(container => {
                if(container) container.innerHTML = '';
            });

            data.forEach(tool => {
                const buttonText = (tool.category === 'other') ? 'Читать далее' : 'Подробнее и скачать';

                const toolCardHTML = `
                    <div class="col-md-6 col-lg-4">
                        <div class="card h-100">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title">${tool.title}</h5>
                                <p class="card-text">${tool.short_description}</p>
                                <a href="pages/details.html?id=${tool.id}" class="btn btn-primary mt-auto">${buttonText}</a>
                            </div>
                        </div>
                    </div>
                `;

                const category = tool.category || 'other';
                if (containers[category]) {
                    containers[category].insertAdjacentHTML('beforeend', toolCardHTML);
                    hasContent[category] = true;
                }
            });

            for (const category in hasContent) {
                if (!hasContent[category] && containers[category]) {
                    containers[category].innerHTML = '<p class="text-muted">Инструментов в этой категории пока нет.</p>';
                }
            }
        })
        .catch(error => {
            console.error('Ошибка при загрузке данных:', error);
            if(containers.lisp) containers.lisp.innerHTML = '<p class="text-danger">Не удалось загрузить список инструментов.</p>';
        });
});
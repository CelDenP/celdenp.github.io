document.addEventListener('DOMContentLoaded', function() {
    const toolsList = document.getElementById('tools-list');
    if (!toolsList) return;

    fetch('data.json')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            toolsList.innerHTML = '';
            data.forEach(tool => {
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
                toolsList.insertAdjacentHTML('beforeend', toolCardHTML);
            });
        })
        .catch(error => {
            console.error('Ошибка при загрузке данных:', error);
            toolsList.innerHTML = '<p class="text-danger">Не удалось загрузить список инструментов.</p>';
        });
});
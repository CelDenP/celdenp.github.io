async function initApp() {
    // 1. Мобильное меню
    const navLinks = document.querySelectorAll('.nav-link');
    const menuToggle = document.getElementById('navbarNav');
    if (menuToggle) {
        const bsCollapse = new bootstrap.Collapse(menuToggle, {toggle: false});
        navLinks.forEach((l) => l.addEventListener('click', () => {
            if(menuToggle.classList.contains('show')) bsCollapse.hide();
        }));
    }

    // 2. Логика возврата наверх и адаптации цвета хедера
    function updateColors() {
        const backToTopBtn = document.getElementById('backToTopBtn');
        const headerGlass = document.getElementById('headerGlass');
        const lightSections = document.querySelectorAll('.section-light');
        const scrollY = window.scrollY;
        
        if (backToTopBtn) {
            if (scrollY > 300) backToTopBtn.classList.add('show');
            else backToTopBtn.classList.remove('show');
            
            const btnRect = backToTopBtn.getBoundingClientRect();
            const btnCenterY = btnRect.top + btnRect.height / 2;
            let buttonOverLight = false;
            lightSections.forEach(section => {
                const rect = section.getBoundingClientRect();
                if (btnCenterY >= rect.top && btnCenterY <= rect.bottom) buttonOverLight = true;
            });
            if (buttonOverLight) { backToTopBtn.classList.add('btn-on-light'); backToTopBtn.classList.remove('btn-on-dark'); }
            else { backToTopBtn.classList.add('btn-on-dark'); backToTopBtn.classList.remove('btn-on-light'); }
        }

        if (headerGlass) {
            const headerCheckY = 50; 
            let headerOverLight = false;
            
            lightSections.forEach(section => {
                const rect = section.getBoundingClientRect();
                if (headerCheckY >= rect.top && headerCheckY <= rect.bottom) headerOverLight = true;
            });
            
            if (headerOverLight) {
                headerGlass.classList.add('glass-header-light');
                headerGlass.classList.remove('glass-header-dark');
            } else {
                headerGlass.classList.add('glass-header-dark');
                headerGlass.classList.remove('glass-header-light');
            }
        }
    }

    window.addEventListener('scroll', updateColors);
    window.addEventListener('resize', updateColors);
    
    const backBtn = document.getElementById('backToTopBtn');
    if (backBtn) backBtn.addEventListener('click', (e) => { e.preventDefault(); window.scrollTo({ top: 0, behavior: 'smooth' }); });

    // ==========================================
    // ЛОГИКА ОТРИСОВКИ КОНТЕНТА ИЗ data.json
    // ==========================================
    try {
        const response = await fetch(`data.json?v=${Date.now()}`);
        const db = await response.json();
        
        const pageType = document.body.getAttribute('data-page');

        if (pageType === 'index') renderIndex(db);
        if (pageType === 'catalog') renderCatalog(db);
        if (pageType === 'service') renderService(db);
        
        // После генерации HTML применяем правильный цвет хедера
        setTimeout(updateColors, 100);

    } catch (err) {
        console.error("Ошибка загрузки data.json", err);
    }
}

// Рендер Главной страницы
function renderIndex(db) {
    const navContainer = document.getElementById('nav-links-container');
    const content = document.getElementById('dynamic-content');
    if (!content) return;

    let html = '';
    let navHtml = '';

    if(db.categories) {
        db.categories.forEach((cat, index) => {
            // Чередование цветов (0-й - светлый, 1-й - темный, 2-й - светлый и т.д.)
            const isLight = (index % 2 === 0);
            const sectionClass = isLight ? 'section-light' : 'section-dark';
            const cardGlassClass = isLight ? 'glass-dark' : '';
            const btnClass = isLight ? 'btn-dark-glass' : 'glass-btn';
            
            navHtml += `<li class="nav-item"><a class="nav-link" href="#${cat.id}">${cat.title}</a></li>`;

            // Берем максимум 3 карточки для главной
            const items = cat.items || [];
            const previewItems = items.slice(0, 3);
            let cardsHtml = '';
            
            previewItems.forEach(item => {
                cardsHtml += `
                    <div class="col-lg-4 col-md-6">
                        <a href="service.html?id=${item.id}" class="project-link">
                            <div class="glass-container ${cardGlassClass} glass-container--rounded h-100 hover-lift">
                                <div class="glass-specular"></div>
                                <div class="glass-content flex-column p-4 text-center">
                                    <div class="icon-box">${item.icon}</div>
                                    <h4 class="mb-3">${item.name}</h4>
                                    <p class="opacity-75 small" style="display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden;">${item.desc}</p>
                                    <span class="badge ${isLight ? 'bg-secondary' : 'bg-light text-dark'} mt-auto">v ${item.version}</span>
                                </div>
                            </div>
                        </a>
                    </div>
                `;
            });

            html += `
                <section id="${cat.id}" class="${sectionClass} py-5 border-top border-secondary">
                    <div class="container py-5">
                        <h2 class="text-center mb-5">${cat.title}</h2>
                        <div class="row g-4 justify-content-center">
                            ${cardsHtml || '<p class="text-center">В этой секции пока нет файлов.</p>'}
                        </div>
                        ${items.length > 0 ? `
                        <div class="text-center mt-5">
                            <a href="catalog.html?category=${cat.id}" class="btn ${btnClass} px-5 py-2">Показать все (${items.length})</a>
                        </div>` : ''}
                    </div>
                </section>
            `;
        });
    }
    
    if(navContainer) navContainer.innerHTML = navHtml;
    content.innerHTML = html;

    // --- УМНОЕ ЧЕРЕДОВАНИЕ ЦВЕТА ФУТЕРА ---
    const footer = document.getElementById('contacts');
    if (footer) {
        // Если количество секций четное (Напр: 2), то последняя секция ТЕМНАЯ (индекс 1). 
        // Значит футер должен стать СВЕТЛЫМ, чтобы не сливаться.
        if (db.categories && db.categories.length % 2 === 0) {
            footer.classList.remove('section-dark', 'border-secondary');
            footer.classList.add('section-light', 'border-dark');
            
            // Стекло внутри футера делаем темным, чтобы текст был читаем
            const footerGlasses = footer.querySelectorAll('.glass-container');
            footerGlasses.forEach(g => g.classList.add('glass-dark'));
        } else {
            // Если секций нечетное, всё по стандарту - Футер темный
            footer.classList.remove('section-light', 'border-dark');
            footer.classList.add('section-dark', 'border-secondary');
            
            const footerGlasses = footer.querySelectorAll('.glass-container');
            footerGlasses.forEach(g => g.classList.remove('glass-dark'));
        }
    }
}

// Рендер страницы "Показать все"
function renderCatalog(db) {
    const params = new URLSearchParams(window.location.search);
    const catId = params.get('category');
    const titleEl = document.getElementById('catalog-title');
    const gridEl = document.getElementById('catalog-grid');
    
    if(!catId || !db.categories) { titleEl.innerText = "Категория не найдена"; return; }
    
    const cat = db.categories.find(c => c.id === catId);
    if(!cat) { titleEl.innerText = "Категория не найдена"; return; }
    
    titleEl.innerText = cat.title;
    
    let html = '';
    (cat.items || []).forEach(item => {
        html += `
            <div class="col-lg-4 col-md-6">
                <a href="service.html?id=${item.id}" class="project-link">
                    <div class="glass-container glass-container--rounded h-100 hover-lift">
                        <div class="glass-specular"></div>
                        <div class="glass-content flex-column p-4 text-center">
                            <div class="icon-box">${item.icon}</div>
                            <h4 class="mb-3">${item.name}</h4>
                            <p class="opacity-75 small" style="display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden;">${item.desc}</p>
                            <span class="badge bg-secondary mt-auto">v ${item.version}</span>
                        </div>
                    </div>
                </a>
            </div>
        `;
    });
    gridEl.innerHTML = html || '<p class="text-center w-100">Файлов нет.</p>';
}

// Рендер страницы конкретного файла
function renderService(db) {
    const params = new URLSearchParams(window.location.search);
    const itemId = params.get('id');
    if(!itemId || !db.categories) return;

    let foundItem = null;
    for(let cat of db.categories) {
        if(cat.items) {
            foundItem = cat.items.find(i => i.id === itemId);
            if(foundItem) break;
        }
    }

    if(!foundItem) {
        document.getElementById('item-name').innerText = "Файл не найден";
        document.getElementById('item-desc').innerText = "Возможно файл был удален.";
        return;
    }

    document.getElementById('item-icon').innerText = foundItem.icon;
    document.getElementById('item-name').innerText = foundItem.name;
    document.getElementById('item-desc').innerText = foundItem.desc;
    document.getElementById('item-version').innerText = foundItem.version || '-';
    document.getElementById('item-size').innerText = foundItem.size || '-';
    
    const btn = document.getElementById('item-download');
    if(foundItem.file) {
        btn.href = foundItem.file;
    } else {
        btn.style.display = 'none';
    }
}

if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', initApp); } 
else { initApp(); }
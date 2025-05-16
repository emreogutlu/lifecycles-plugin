document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.issue-popup').forEach(function (el) {
        el.addEventListener('click', function (e) {
            e.preventDefault();

            const issueId = this.getAttribute('data-issue-id'); // get the issue_id from the link

            const projectId = document.querySelector('#project_id').value;
            const userId = document.querySelector('#user_id')?.value || '';
            const categoryId = document.querySelector('#category_id')?.value || '';

            const url = new URL('/lifecycles/popup', window.location.origin);
            url.searchParams.append('issue_id', issueId);
            url.searchParams.append('project_id', projectId);
            if (userId) url.searchParams.append('user_id', userId);
            if (categoryId) url.searchParams.append('category_id', categoryId);

            fetch(url.toString()) // send the parameters in the query string
            .then(response => response.text())
            .then(html => {
                const modal = document.createElement('div');
                modal.classList.add('popup-modal');
                modal.innerHTML = html;

                modal.querySelectorAll('.popup-content script').forEach((script) => {
                    if (!script.src) {
                        const newScript = document.createElement('script');
                        newScript.text = script.textContent;
                        script.parentNode.replaceChild(newScript, script);
                    }
                });

                document.body.appendChild(modal);

                // close the popup
                modal.querySelector('.popup-close').addEventListener('click', () => modal.remove());
                modal.addEventListener('click', (ev) => {
                    if (ev.target === modal) modal.remove();
                });
            });
        });
    });
});
  
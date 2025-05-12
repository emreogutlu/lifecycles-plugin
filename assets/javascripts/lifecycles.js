document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.issue-popup').forEach(function (el) {
        el.addEventListener('click', function (e) {
            e.preventDefault();

            const issueId = this.getAttribute('data-issue-id'); // get the issue_id from the link

            fetch(`/lifecycles/popup?issue_id=${issueId}`) // send the issue_id in the query string
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
  
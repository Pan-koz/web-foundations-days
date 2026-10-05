const noteText = document.querySelector("#note-text");
const charCount = document.querySelector("#char-count");
const wordCount = document.querySelector("#word-count");
const clearBtn = document.querySelector("#clear-btn");
const themeToggle = document.querySelector("#theme-toggle");

function updateCounts() {
  const text = noteText.value;
  const characters = text.length;
  const words = text.trim() === "" ? 0 : text.trim().split(/\s+/).length;

  charCount.textContent = `${characters} / 200 characters`;
  wordCount.textContent = `${words} words`;

  charCount.classList.remove("warning", "over");

  if (characters > 200) {
    charCount.classList.add("over");
  } else if (characters > 180) {
    charCount.classList.add("warning");
  }
}

noteText.addEventListener("input", () => {
  updateCounts();
  localStorage.setItem("quicknotes-draft", noteText.value);
});
const savedDraft = localStorage.getItem("quicknotes-draft");

if (savedDraft !== null) {
  noteText.value = savedDraft;
}

const savedTheme = localStorage.getItem("quicknotes-theme");

if (savedTheme === "dark") {
  document.body.classList.add("dark");
  themeToggle.textContent = "Light mode";
}

updateCounts();
function clearEverything() {
  noteText.value = "";
  localStorage.removeItem("quicknotes-draft");
  updateCounts();
  noteText.focus();
}
clearBtn.addEventListener("click", clearEverything);
noteText.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    clearEverything();
  }
});
themeToggle.addEventListener("click", () => {
  document.body.classList.toggle("dark");

  const isDark = document.body.classList.contains("dark");

  themeToggle.textContent = isDark ? "Light mode" : "Dark mode";

  localStorage.setItem(
    "quicknotes-theme",
    isDark ? "dark" : "light"
  );
});
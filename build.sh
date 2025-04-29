#!/bin/bash

# filepath: build.sh

# Змінні для конфігурації збірки
PYODIDE_FORK_DIR="./pyodide-fork"
PYODIDE_ENV_NAME="pyodide-build-env"

# Перевірка наявності каталогу pyodide
if [ ! -d "$PYODIDE_FORK_DIR" ]; then
  echo "Помилка: Каталог pyodide не знайдено. Переконайтеся, що ви ініціалізували та оновили підмодулі."
  exit 1
fi

# Функція для створення та активації conda environment
create_conda_env() {
  if conda env list | grep -q "$PYODIDE_ENV_NAME"; then
    echo "Conda environment '$PYODIDE_ENV_NAME' вже існує."
  else
    echo "Створення conda environment '$PYODIDE_ENV_NAME'..."
    conda create -n "$PYODIDE_ENV_NAME" python=3.9 -y
    if [ $? -ne 0 ]; then
      echo "Помилка: Не вдалося створити conda environment."
      exit 1
    fi
  fi
  source $(conda info --envroot)/etc/profile.d/conda.sh
  conda activate "$PYODIDE_ENV_NAME"
}

# Функція для встановлення залежностей pyodide
install_pyodide_dependencies() {
  echo "Встановлення залежностей pyodide..."
  pip install -r "$PYODIDE_FORK_DIR/requirements-dev.txt"
  if [ $? -ne 0 ]; then
    echo "Помилка: Не вдалося встановити залежності pyodide."
    exit 1
  fi
  conda install -c conda-forge emscripten -y
  if [ $? -ne 0 ]; then
    echo "Помилка: Не вдалося встановити emscripten."
    exit 1
  fi
}

# Функція для збірки pyodide
build_pyodide() {
  echo "Збірка pyodide..."
  cd "$PYODIDE_FORK_DIR"
  python setup.py build_ext -i
  if [ $? -ne 0 ]; then
    echo "Помилка: Не вдалося зібрати pyodide."
    exit 1
  fi
  cd ..
}

# Головна функція
main() {
  create_conda_env
  install_pyodide_dependencies
  build_pyodide
  echo "Збірка pyodide завершена."
}

# Запуск головної функції
main
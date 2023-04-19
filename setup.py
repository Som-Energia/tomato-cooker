#!/usr/bin/env python
from setuptools import find_packages, setup

from tomato_cooker.__init__ import VERSION

readme = open("README.md").read()

required = ["minizinc", "pyyaml"]

extras = {
    "dev": [
        "isort",
        "flake8",
        "black",
        "pre-commit",
        "gitlint",
    ],
    "tests": [
        "pytest",
        "pytest-asyncio",
        "pytest-cov",
    ],
}

setup(
    name="tomato-cooker",
    version=VERSION,
    description="Minizinc problem solver",
    author="Som Energia SCCL",
    author_email="info@somenergia.coop",
    url="https://github.com/Som-Energia/Som-Minizinc",
    long_description=readme,
    long_description_content_type="text/markdown",
    license="GNU Affero General Public License v3 or later (AGPLv3+)",
    packages=find_packages(exclude=["*[tT]est*"]),
    python_requires=">=3.8.0",
    zip_safe=True,
    setup_requires=[],
    install_requires=required,
    extras_require=extras,
    scripts=[],
    include_package_data=True,
    test_suite="pytest",
    classifiers=[
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Intended Audience :: Developers",
        "Development Status :: 2 - Pre-Alpha",
        "License :: OSI Approved :: GNU Affero General Public License v3 or later (AGPLv3+)",
        "Operating System :: POSIX :: Linux",
        "Operating System :: MacOS",
    ],
)

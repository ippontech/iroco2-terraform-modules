module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'body-max-line-length': [2, 'always', 400],
        'header-max-length': [2, 'always', 120],
    },
};

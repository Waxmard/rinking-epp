const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Suppress useInsertionEffect warnings in development
config.resolver.alias = {
  ...config.resolver.alias,
};

module.exports = config;

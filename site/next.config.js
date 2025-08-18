/** @type {import('next').NextConfig} */

const nextConfig = {
  output: 'export',
  distDir: '../public',
  env: {
    name: 'Skylus Workspaces',
    description: 'The Marketplace for Skylus Workspaces.',
    icon: '/img/logo.svg',
    listUrl: 'https://netweb-technologies.github.io/skylus-marketplace/',
    contactUrl: 'https://kasmweb.com/support',
  },
  reactStrictMode: true,
  basePath: '/skylus-marketplace/1.0',
  trailingSlash: true,
  images: {
    unoptimized: true,
  }
}

module.exports = nextConfig

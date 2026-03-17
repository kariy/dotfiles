// worker/index.js
var RAW_URL = "https://raw.githubusercontent.com/kariy/dotfiles/dotfiles/scripts/install.sh";
var index_default = {
  async fetch() {
    const res = await fetch(RAW_URL);
    return new Response(res.body, {
      headers: {
        "content-type": "text/plain; charset=utf-8",
        "cache-control": "public, max-age=300"
      }
    });
  }
};
export {
  index_default as default
};
//# sourceMappingURL=index.js.map

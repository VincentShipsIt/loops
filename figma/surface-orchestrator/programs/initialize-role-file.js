/*__FIGMA_INPUT__*/

if (typeof INPUT.pageId !== "string" || INPUT.pageId.length === 0) {
  throw new Error("pageId must be a non-empty string");
}
if (typeof INPUT.pageName !== "string" || INPUT.pageName.trim().length === 0) {
  throw new Error("pageName must be a non-empty string");
}

const backgroundHex = INPUT.backgroundHex ?? "#2B2B2B";
if (!/^#[0-9A-Fa-f]{6}$/.test(backgroundHex)) {
  throw new Error("backgroundHex must use #RRGGBB format");
}

const page = await figma.getNodeByIdAsync(INPUT.pageId);
if (!page || page.type !== "PAGE") {
  throw new Error(`Page not found: ${INPUT.pageId}`);
}
await figma.setCurrentPageAsync(page);

const before = {
  name: page.name,
  backgrounds: page.backgrounds,
  prototypeBackgrounds: page.prototypeBackgrounds,
};
const channel = (offset) => parseInt(backgroundHex.slice(offset, offset + 2), 16) / 255;
const paint = {
  type: "SOLID",
  color: {
    r: channel(1),
    g: channel(3),
    b: channel(5),
  },
};

page.name = INPUT.pageName.trim();
page.backgrounds = [paint];
page.prototypeBackgrounds = [paint];

return {
  mutatedNodeIds: [page.id],
  before,
  after: {
    id: page.id,
    name: page.name,
    backgrounds: page.backgrounds,
    prototypeBackgrounds: page.prototypeBackgrounds,
  },
};

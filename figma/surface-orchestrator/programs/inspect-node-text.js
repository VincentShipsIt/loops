/*__FIGMA_INPUT__*/

if (typeof INPUT.pageId !== "string" || INPUT.pageId.length === 0) {
  throw new Error("pageId must be a non-empty string");
}
if (typeof INPUT.nodeId !== "string" || INPUT.nodeId.length === 0) {
  throw new Error("nodeId must be a non-empty string");
}

const page = await figma.getNodeByIdAsync(INPUT.pageId);
if (!page || page.type !== "PAGE") {
  throw new Error(`Page not found: ${INPUT.pageId}`);
}
await figma.setCurrentPageAsync(page);

const target = await figma.getNodeByIdAsync(INPUT.nodeId);
if (!target) {
  throw new Error(`Node not found: ${INPUT.nodeId}`);
}
let targetPage = target;
while (targetPage.parent && targetPage.type !== "PAGE") {
  targetPage = targetPage.parent;
}
if (target.id !== page.id && targetPage.id !== page.id) {
  throw new Error(`Node ${INPUT.nodeId} does not belong to page ${INPUT.pageId}`);
}

let textNodes = [];
if (target.type === "TEXT") {
  textNodes = [target];
} else if ("findAllWithCriteria" in target) {
  textNodes = target.findAllWithCriteria({ types: ["TEXT"] });
}

return {
  page: {
    id: page.id,
    name: page.name,
  },
  target: {
    id: target.id,
    name: target.name,
    type: target.type,
  },
  textCount: textNodes.length,
  texts: textNodes.map((node) => ({
    id: node.id,
    name: node.name,
    characters: node.characters,
  })),
};

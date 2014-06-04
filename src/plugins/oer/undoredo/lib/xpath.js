define(function(){

  /**
   * Gets an XPath for an node which describes its hierarchical location.
   */
  var getNodeXPath = function(node) {
      if (node && node.id)
          return '//*[@id="' + node.id + '"]';
      else if (node.nodeType == 3)
          return getNodeTreeXPath(node.parentNode);
      else
          return getNodeTreeXPath(node);
  };
  
  var getNodeTreeXPath = function(node) {
      var paths = [];
  
      // Use nodeName (instead of localName) so namespace prefix is included (if any).
      for (; node && (node.nodeType == 1) ; node = node.parentNode)  {
          var index = 0;
          if (node && node.id) {
              paths.splice(0, 0, '/*[@id="' + node.id + '"]');
              break;
          }
  
          for (var sibling = node.previousSibling; sibling; sibling = sibling.previousSibling) {
              // Ignore document type declaration.
              if (sibling.nodeType == Node.DOCUMENT_TYPE_NODE)
                  continue;
  
              if (sibling.nodeName == node.nodeName)
                  ++index;
          }
  
          var tagName = node.nodeName.toLowerCase();
          var pathIndex = (index ? "[" + (index+1) + "]" : "");
          paths.splice(0, 0, tagName + pathIndex);
      }
  
      return paths.length ? "/" + paths.join("/") : null;
  };

  var findNode = function(xpath, ctx) {
    var r = document.evaluate(xpath, ctx || document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    return r.singleNodeValue;
  };

  return {
    xpathFor: getNodeXPath,
    nodeFor: findNode
  };
});

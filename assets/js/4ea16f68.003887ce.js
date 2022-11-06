"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[669],{3905:(e,t,n)=>{n.d(t,{Zo:()=>c,kt:()=>f});var r=n(67294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function s(e,t){if(null==e)return{};var n,r,o=function(e,t){if(null==e)return{};var n,r,o={},a=Object.keys(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var l=r.createContext({}),p=function(e){var t=r.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},c=function(e){var t=p(e.components);return r.createElement(l.Provider,{value:t},e.children)},d={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},u=r.forwardRef((function(e,t){var n=e.components,o=e.mdxType,a=e.originalType,l=e.parentName,c=s(e,["components","mdxType","originalType","parentName"]),u=p(n),f=o,h=u["".concat(l,".").concat(f)]||u[f]||d[f]||a;return n?r.createElement(h,i(i({ref:t},c),{},{components:n})):r.createElement(h,i({ref:t},c))}));function f(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var a=n.length,i=new Array(a);i[0]=u;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s.mdxType="string"==typeof e?e:o,i[1]=s;for(var p=2;p<a;p++)i[p]=n[p];return r.createElement.apply(null,i)}return r.createElement.apply(null,n)}u.displayName="MDXCreateElement"},40839:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>l,contentTitle:()=>i,default:()=>d,frontMatter:()=>a,metadata:()=>s,toc:()=>p});var r=n(87462),o=(n(67294),n(3905));const a={sidebar_position:2},i="Key Differences to Roact",s={unversionedId:"KeyDifferences-Roact",id:"KeyDifferences-Roact",title:"Key Differences to Roact",description:"Features",source:"@site/docs/KeyDifferences-Roact.md",sourceDirName:".",slug:"/KeyDifferences-Roact",permalink:"/feather/docs/KeyDifferences-Roact",draft:!1,editUrl:"https://github.com/blinkybool/feather/edit/main/docs/KeyDifferences-Roact.md",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"defaultSidebar",previous:{title:"Basic Usage",permalink:"/feather/docs/intro"},next:{title:"Optimising",permalink:"/feather/docs/Optimising"}},l={},p=[{value:"Features",id:"features",level:2},{value:"Host Elements",id:"host-elements",level:2},{value:"Host Children",id:"host-children",level:2},{value:"Host Props",id:"host-props",level:2},{value:"Function components are pure",id:"function-components-are-pure",level:2}],c={toc:p};function d(e){let{components:t,...n}=e;return(0,o.kt)("wrapper",(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"key-differences-to-roact"},"Key Differences to Roact"),(0,o.kt)("h2",{id:"features"},"Features"),(0,o.kt)("p",null,"There is no support for events, state, hooks, lifecycle methods, context etc. Feather is supposed to be simple and lightweight so it can handle many instances, and is not intended to be a replacement for Roact. However you could certainly make use of Feather ",(0,o.kt)("em",{parentName:"p"},"within")," a Roact component, by calling ",(0,o.kt)("inlineCode",{parentName:"p"},"Feather.mount"),", ",(0,o.kt)("inlineCode",{parentName:"p"},"Feather.update")," and ",(0,o.kt)("inlineCode",{parentName:"p"},"Feather.unmount")," in ",(0,o.kt)("inlineCode",{parentName:"p"},"Component:didMount"),", ",(0,o.kt)("inlineCode",{parentName:"p"},"Component:didUpdate")," and ",(0,o.kt)("inlineCode",{parentName:"p"},"Component:willUnmount")," respectively."),(0,o.kt)("h2",{id:"host-elements"},"Host Elements"),(0,o.kt)("p",null,"It is assumed that the instance class does not change for a fixed key. This avoids reading ",(0,o.kt)("inlineCode",{parentName:"p"},"Instance.ClassName"),", which (I think) is costly for many instances, and also avoids the alternative solution of storing the class name in memory. If it seems necessary to change the class of an instance, consider using a different key, or restructuring your tree so that the other-class version of some host lives on a different branch."),(0,o.kt)("h2",{id:"host-children"},"Host Children"),(0,o.kt)("p",null,"In Roact you can pass the children table to the ",(0,o.kt)("inlineCode",{parentName:"p"},"[Roact.Children]")," key of the prop table, or as the third argument of ",(0,o.kt)("inlineCode",{parentName:"p"},"Roact.createElement"),". ",(0,o.kt)("inlineCode",{parentName:"p"},"Feather.createElement")," does not support an optional children argument - you must use the ",(0,o.kt)("a",{parentName:"p",href:"/api/Feather#Children"},"Feather.Children")," or ",(0,o.kt)("a",{parentName:"p",href:"/api/Feather#DeltaChildren"},"Feather.DeltaChildren")," key. This makes it more explicit which kind is in use."),(0,o.kt)("h2",{id:"host-props"},"Host Props"),(0,o.kt)("p",null,"Feather does not store host props, so it cannot revert a host property to the default value if it is missing from the props table. For example, the following update would not set the part color back to the default color (like it would in Roact)."),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},"Feather.update(tree, e(sphere, {\n\n    Diameter = 2,\n    Position = Vector3.new(0,5,0),\n}))\n")),(0,o.kt)("p",null,"However, this can be exploited for performance by performing only the necessary updates to props (see ",(0,o.kt)("a",{parentName:"p",href:"/docs/Optimising"},"Optimising"),")\nThis makes Feather ",(0,o.kt)("strong",{parentName:"p"},"not")," ",(0,o.kt)("em",{parentName:"p"},"truly declarative"),", and the props table for hosts should be considered as an update-table, not a complete description of the host properties."),(0,o.kt)("h2",{id:"function-components-are-pure"},"Function components are pure"),(0,o.kt)("p",null,"Function components are treated as ",(0,o.kt)("em",{parentName:"p"},"pure")," by default, meaning if there are no differences in the keys and values of the old and new props, the update process will shortcut."))}d.isMDXComponent=!0}}]);
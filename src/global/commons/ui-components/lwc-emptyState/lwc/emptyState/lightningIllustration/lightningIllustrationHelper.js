import { illustrations1 } from './lightningIllustration1';
import { illustrations2 } from './lightningIllustration2';
import { illustrations3 } from './lightningIllustration3';
const getSvg = (name) => {
    if (illustrations1.hasOwnProperty(name)) return illustrations1[name];
    if (illustrations2.hasOwnProperty(name)) return illustrations2[name];
    return illustrations3[name];
};
export { getSvg };
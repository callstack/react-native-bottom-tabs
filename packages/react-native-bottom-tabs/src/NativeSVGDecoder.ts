import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {}

export default TurboModuleRegistry.getEnforcing<Spec>('SvgDecoder');

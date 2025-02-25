import 'package:dartx/dartx.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/core/model/region.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/core/utils/json_converters.dart';
import 'package:hiddify/core/utils/preferences_utils.dart';
import 'package:hiddify/features/config_option/model/config_option_failure.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_data_providers.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_path_resolver.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_repository.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ConfigOptions {
  static final serviceMode = PreferencesNotifier.create<ServiceMode, String>(
    "service-mode",
    ServiceMode.defaultMode,
    mapFrom: (value) => ServiceMode.choices.firstWhere((e) => e.key == value),
    mapTo: (value) => value.key,
  );

  static final logLevel = PreferencesNotifier.create<LogLevel, String>(
    "log-level",
    LogLevel.warn,
    mapFrom: LogLevel.values.byName,
    mapTo: (value) => value.name,
  );

  static final resolveDestination = PreferencesNotifier.create<bool, bool>(
    "resolve-destination",
    false,
  );

  static final ipv6Mode = PreferencesNotifier.create<IPv6Mode, String>(
    "ipv6-mode",
    IPv6Mode.disable,
    mapFrom: (value) => IPv6Mode.values.firstWhere((e) => e.key == value),
    mapTo: (value) => value.key,
  );

  static final remoteDnsAddress = PreferencesNotifier.create<String, String>(
    "remote-dns-address",
    "udp://1.1.1.1",
    validator: (value) => value.isNotBlank,
  );

  static final remoteDnsDomainStrategy =
      PreferencesNotifier.create<DomainStrategy, String>(
    "remote-dns-domain-strategy",
    DomainStrategy.auto,
    mapFrom: (value) => DomainStrategy.values.firstWhere((e) => e.key == value),
    mapTo: (value) => value.key,
  );

  static final directDnsAddress = PreferencesNotifier.create<String, String>(
    "direct-dns-address",
    "1.1.1.1",
    validator: (value) => value.isNotBlank,
  );

  static final directDnsDomainStrategy =
      PreferencesNotifier.create<DomainStrategy, String>(
    "direct-dns-domain-strategy",
    DomainStrategy.auto,
    mapFrom: (value) => DomainStrategy.values.firstWhere((e) => e.key == value),
    mapTo: (value) => value.key,
  );

  static final mixedPort = PreferencesNotifier.create<int, int>(
    "mixed-port",
    2334,
    validator: (value) => isPort(value.toString()),
  );

  static final localDnsPort = PreferencesNotifier.create<int, int>(
    "local-dns-port",
    6450,
    validator: (value) => isPort(value.toString()),
  );

  static final tunImplementation =
      PreferencesNotifier.create<TunImplementation, String>(
    "tun-implementation",
    TunImplementation.mixed,
    mapFrom: TunImplementation.values.byName,
    mapTo: (value) => value.name,
  );

  static final mtu = PreferencesNotifier.create<int, int>("mtu", 9000);

  static final strictRoute =
      PreferencesNotifier.create<bool, bool>("strict-route", true);

  static final connectionTestUrl = PreferencesNotifier.create<String, String>(
    "connection-test-url",
    "http://cp.cloudflare.com/",
    validator: (value) => value.isNotBlank && isUrl(value),
  );

  static final urlTestInterval = PreferencesNotifier.create<Duration, int>(
    "url-test-interval",
    const Duration(minutes: 10),
    mapFrom: const IntervalInSecondsConverter().fromJson,
    mapTo: const IntervalInSecondsConverter().toJson,
  );

  static final enableClashApi = PreferencesNotifier.create<bool, bool>(
    "enable-clash-api",
    true,
  );

  static final clashApiPort = PreferencesNotifier.create<int, int>(
    "clash-api-port",
    6756,
    validator: (value) => isPort(value.toString()),
  );

  static final bypassLan =
      PreferencesNotifier.create<bool, bool>("bypass-lan", false);

  static final allowConnectionFromLan = PreferencesNotifier.create<bool, bool>(
    "allow-connection-from-lan",
    false,
  );

  static final enableFakeDns = PreferencesNotifier.create<bool, bool>(
    "enable-fake-dns",
    false,
  );

  static final enableDnsRouting = PreferencesNotifier.create<bool, bool>(
    "enable-dns-routing",
    true,
  );

  static final independentDnsCache = PreferencesNotifier.create<bool, bool>(
    "independent-dns-cache",
    true,
  );

  static final enableTlsFragment = PreferencesNotifier.create<bool, bool>(
    "enable-tls-fragment",
    false,
  );

  static final tlsFragmentSize =
      PreferencesNotifier.create<OptionalRange, String>(
    "tls-fragment-size",
    const OptionalRange(min: 1, max: 500),
    mapFrom: OptionalRange.parse,
    mapTo: const OptionalRangeJsonConverter().toJson,
  );

  static final tlsFragmentSleep =
      PreferencesNotifier.create<OptionalRange, String>(
    "tls-fragment-sleep",
    const OptionalRange(min: 0, max: 500),
    mapFrom: OptionalRange.parse,
    mapTo: const OptionalRangeJsonConverter().toJson,
  );

  static final enableTlsMixedSniCase = PreferencesNotifier.create<bool, bool>(
    "enable-tls-mixed-sni-case",
    false,
  );

  static final enableTlsPadding = PreferencesNotifier.create<bool, bool>(
    "enable-tls-padding",
    false,
  );

  static final tlsPaddingSize =
      PreferencesNotifier.create<OptionalRange, String>(
    "tls-padding-size",
    const OptionalRange(min: 1, max: 1500),
    mapFrom: OptionalRange.parse,
    mapTo: const OptionalRangeJsonConverter().toJson,
  );

  static final enableMux = PreferencesNotifier.create<bool, bool>(
    "enable-mux",
    false,
  );

  static final muxPadding = PreferencesNotifier.create<bool, bool>(
    "mux-padding",
    false,
  );

  static final muxMaxStreams = PreferencesNotifier.create<int, int>(
    "mux-max-streams",
    8,
    validator: (value) => value > 0,
  );

  static final muxProtocol = PreferencesNotifier.create<MuxProtocol, String>(
    "mux-protocol",
    MuxProtocol.h2mux,
    mapFrom: MuxProtocol.values.byName,
    mapTo: (value) => value.name,
  );

  static final enableWarp = PreferencesNotifier.create<bool, bool>(
    "enable-warp",
    false,
  );

  static final warpDetourMode =
      PreferencesNotifier.create<WarpDetourMode, String>(
    "warp-detour-mode",
    WarpDetourMode.outbound,
    mapFrom: WarpDetourMode.values.byName,
    mapTo: (value) => value.name,
  );

  static final warpLicenseKey = PreferencesNotifier.create<String, String>(
    "warp-license-key",
    "",
  );

  static final warpAccountId = PreferencesNotifier.create<String, String>(
    "warp-account-id",
    "",
  );

  static final warpAccessToken = PreferencesNotifier.create<String, String>(
    "warp-access-token",
    "",
  );

  static final warpCleanIp = PreferencesNotifier.create<String, String>(
    "warp-clean-ip",
    "auto",
  );

  static final warpPort = PreferencesNotifier.create<int, int>(
    "warp-port",
    0,
    validator: (value) => isPort(value.toString()),
  );

  static final warpNoise = PreferencesNotifier.create<OptionalRange, String>(
    "warp-noise",
    const OptionalRange(min: 5, max: 10),
    mapFrom: (value) => OptionalRange.parse(value, allowEmpty: true),
    mapTo: const OptionalRangeJsonConverter().toJson,
  );

  static final warpNoiseDelay =
      PreferencesNotifier.create<OptionalRange, String>(
    "warp-noise-delay",
    const OptionalRange(min: 20, max: 200),
    mapFrom: (value) => OptionalRange.parse(value, allowEmpty: true),
    mapTo: const OptionalRangeJsonConverter().toJson,
  );

  static final warpWireguardConfig = PreferencesNotifier.create<String, String>(
    "warp-wireguard-config",
    "",
  );

  static final hasExperimentalFeatures = Provider.autoDispose<bool>(
    (ref) {
      final mode = ref.watch(serviceMode);
      if (PlatformUtils.isDesktop && mode == ServiceMode.tun) {
        return true;
      }
      if (ref.watch(enableTlsFragment) ||
          ref.watch(enableTlsMixedSniCase) ||
          ref.watch(enableTlsPadding) ||
          ref.watch(enableMux) ||
          ref.watch(enableWarp)) {
        return true;
      }

      return false;
    },
  );

  /// list of all config option preferences
  static final preferences = [
    serviceMode,
    logLevel,
    resolveDestination,
    ipv6Mode,
    remoteDnsAddress,
    remoteDnsDomainStrategy,
    directDnsAddress,
    directDnsDomainStrategy,
    mixedPort,
    localDnsPort,
    tunImplementation,
    mtu,
    strictRoute,
    connectionTestUrl,
    urlTestInterval,
    clashApiPort,
    bypassLan,
    allowConnectionFromLan,
    enableDnsRouting,
    enableTlsFragment,
    tlsFragmentSize,
    tlsFragmentSleep,
    enableTlsMixedSniCase,
    enableTlsPadding,
    tlsPaddingSize,
    enableMux,
    muxPadding,
    muxMaxStreams,
    muxProtocol,
    enableWarp,
    warpDetourMode,
    warpLicenseKey,
    warpAccountId,
    warpAccessToken,
    warpCleanIp,
    warpPort,
    warpNoise,
    warpWireguardConfig,
  ];

  static final singboxConfigOptions = FutureProvider<SingboxConfigOption>(
    (ref) async {
      final region = ref.watch(Preferences.region);
      final rules = switch (region) {
        Region.ir => [
            const SingboxRule(
              domains: "domain:.ir,geosite:ir",
              ip: "geoip:ir",
              outbound: RuleOutbound.bypass,
            ),
          ],
        Region.cn => [
            const SingboxRule(
              domains: "domain:.cn,geosite:cn",
              ip: "geoip:cn",
              outbound: RuleOutbound.bypass,
            ),
          ],
        Region.ru => [
            const SingboxRule(
              domains: "domain:.ru",
              ip: "geoip:ru",
              outbound: RuleOutbound.bypass,
            ),
          ],
        Region.af => [
            const SingboxRule(
              domains: "domain:.af,geosite:af",
              ip: "geoip:af",
              outbound: RuleOutbound.bypass,
            ),
          ],
        _ => <SingboxRule>[],
      };

      final geoAssetsRepo = await ref.watch(geoAssetRepositoryProvider.future);
      final geoAssets =
          await geoAssetsRepo.getActivePair().getOrElse((l) => throw l).run();

      final mode = ref.watch(serviceMode);
      return SingboxConfigOption(
        executeConfigAsIs: false,
        logLevel: ref.watch(logLevel),
        resolveDestination: ref.watch(resolveDestination),
        ipv6Mode: ref.watch(ipv6Mode),
        remoteDnsAddress: ref.watch(remoteDnsAddress),
        remoteDnsDomainStrategy: ref.watch(remoteDnsDomainStrategy),
        directDnsAddress: ref.watch(directDnsAddress),
        directDnsDomainStrategy: ref.watch(directDnsDomainStrategy),
        mixedPort: ref.watch(mixedPort),
        localDnsPort: ref.watch(localDnsPort),
        tunImplementation: ref.watch(tunImplementation),
        mtu: ref.watch(mtu),
        strictRoute: ref.watch(strictRoute),
        connectionTestUrl: ref.watch(connectionTestUrl),
        urlTestInterval: ref.watch(urlTestInterval),
        enableClashApi: ref.watch(enableClashApi),
        clashApiPort: ref.watch(clashApiPort),
        enableTun: mode == ServiceMode.tun,
        enableTunService: mode == ServiceMode.tunService,
        setSystemProxy: mode == ServiceMode.systemProxy,
        bypassLan: ref.watch(bypassLan),
        allowConnectionFromLan: ref.watch(allowConnectionFromLan),
        enableFakeDns: ref.watch(enableFakeDns),
        enableDnsRouting: ref.watch(enableDnsRouting),
        independentDnsCache: ref.watch(independentDnsCache),
        enableTlsFragment: ref.watch(enableTlsFragment),
        tlsFragmentSize: ref.watch(tlsFragmentSize),
        tlsFragmentSleep: ref.watch(tlsFragmentSleep),
        enableTlsMixedSniCase: ref.watch(enableTlsMixedSniCase),
        enableTlsPadding: ref.watch(enableTlsPadding),
        tlsPaddingSize: ref.watch(tlsPaddingSize),
        enableMux: ref.watch(enableMux),
        muxPadding: ref.watch(muxPadding),
        muxMaxStreams: ref.watch(muxMaxStreams),
        muxProtocol: ref.watch(muxProtocol),
        warp: SingboxWarpOption(
          enable: ref.watch(enableWarp),
          mode: ref.watch(warpDetourMode),
          wireguardConfig: ref.watch(warpWireguardConfig),
          licenseKey: ref.watch(warpLicenseKey),
          accountId: ref.watch(warpAccountId),
          accessToken: ref.watch(warpAccessToken),
          cleanIp: ref.watch(warpCleanIp),
          cleanPort: ref.watch(warpPort),
          warpNoise: ref.watch(warpNoise),
          warpNoiseDelay: ref.watch(warpNoiseDelay),
        ),
        geoipPath: ref.watch(geoAssetPathResolverProvider).relativePath(
              geoAssets.geoip.providerName,
              geoAssets.geoip.fileName,
            ),
        geositePath: ref.watch(geoAssetPathResolverProvider).relativePath(
              geoAssets.geosite.providerName,
              geoAssets.geosite.fileName,
            ),
        rules: rules,
      );
    },
  );

  /// singbox options
  ///
  /// **this is partial, don't use it directly**
  static SingboxConfigOption singboxOptions(ProviderRef ref) {
    final mode = ref.read(serviceMode);
    return SingboxConfigOption(
      executeConfigAsIs: false,
      logLevel: ref.read(logLevel),
      resolveDestination: ref.read(resolveDestination),
      ipv6Mode: ref.read(ipv6Mode),
      remoteDnsAddress: ref.read(remoteDnsAddress),
      remoteDnsDomainStrategy: ref.read(remoteDnsDomainStrategy),
      directDnsAddress: ref.read(directDnsAddress),
      directDnsDomainStrategy: ref.read(directDnsDomainStrategy),
      mixedPort: ref.read(mixedPort),
      localDnsPort: ref.read(localDnsPort),
      tunImplementation: ref.read(tunImplementation),
      mtu: ref.read(mtu),
      strictRoute: ref.read(strictRoute),
      connectionTestUrl: ref.read(connectionTestUrl),
      urlTestInterval: ref.read(urlTestInterval),
      enableClashApi: ref.read(enableClashApi),
      clashApiPort: ref.read(clashApiPort),
      enableTun: mode == ServiceMode.tun,
      enableTunService: mode == ServiceMode.tunService,
      setSystemProxy: mode == ServiceMode.systemProxy,
      bypassLan: ref.read(bypassLan),
      allowConnectionFromLan: ref.read(allowConnectionFromLan),
      enableFakeDns: ref.read(enableFakeDns),
      enableDnsRouting: ref.read(enableDnsRouting),
      independentDnsCache: ref.read(independentDnsCache),
      enableTlsFragment: ref.read(enableTlsFragment),
      tlsFragmentSize: ref.read(tlsFragmentSize),
      tlsFragmentSleep: ref.read(tlsFragmentSleep),
      enableTlsMixedSniCase: ref.read(enableTlsMixedSniCase),
      enableTlsPadding: ref.read(enableTlsPadding),
      tlsPaddingSize: ref.read(tlsPaddingSize),
      enableMux: ref.read(enableMux),
      muxPadding: ref.read(muxPadding),
      muxMaxStreams: ref.read(muxMaxStreams),
      muxProtocol: ref.read(muxProtocol),
      warp: SingboxWarpOption(
        enable: ref.read(enableWarp),
        mode: ref.read(warpDetourMode),
        wireguardConfig: ref.read(warpWireguardConfig),
        licenseKey: ref.read(warpLicenseKey),
        accountId: ref.read(warpAccountId),
        accessToken: ref.read(warpAccessToken),
        cleanIp: ref.read(warpCleanIp),
        cleanPort: ref.read(warpPort),
        warpNoise: ref.read(warpNoise),
        warpNoiseDelay: ref.read(warpNoiseDelay),
      ),
      geoipPath: "",
      geositePath: "",
      rules: [],
    );
  }
}

class ConfigOptionRepository with ExceptionHandler, InfraLogger {
  ConfigOptionRepository({
    required this.preferences,
    required this.getConfigOptions,
    required this.geoAssetRepository,
    required this.geoAssetPathResolver,
  });

  final SharedPreferences preferences;
  final SingboxConfigOption Function() getConfigOptions;
  final GeoAssetRepository geoAssetRepository;
  final GeoAssetPathResolver geoAssetPathResolver;

  TaskEither<ConfigOptionFailure, SingboxConfigOption>
      getFullSingboxConfigOption() {
    return exceptionHandler(
      () async {
        final region =
            Region.values.byName(preferences.getString("region") ?? "other");
        final rules = switch (region) {
          Region.ir => [
              const SingboxRule(
                domains: "domain:.ir,geosite:ir",
                ip: "geoip:ir",
                outbound: RuleOutbound.bypass,
              ),
            ],
          Region.cn => [
              const SingboxRule(
                domains: "domain:.cn,geosite:cn",
                ip: "geoip:cn",
                outbound: RuleOutbound.bypass,
              ),
            ],
          Region.ru => [
              const SingboxRule(
                domains: "domain:.ru",
                ip: "geoip:ru",
                outbound: RuleOutbound.bypass,
              ),
            ],
          Region.af => [
              const SingboxRule(
                domains: "domain:.af,geosite:af",
                ip: "geoip:af",
                outbound: RuleOutbound.bypass,
              ),
            ],
          _ => <SingboxRule>[],
        };

        final geoAssets = await geoAssetRepository
            .getActivePair()
            .getOrElse((l) => throw l)
            .run();

        final singboxConfigOption = getConfigOptions().copyWith(
          geoipPath: geoAssetPathResolver.relativePath(
            geoAssets.geoip.providerName,
            geoAssets.geoip.fileName,
          ),
          geositePath: geoAssetPathResolver.relativePath(
            geoAssets.geosite.providerName,
            geoAssets.geosite.fileName,
          ),
          rules: rules,
        );
        return right(singboxConfigOption);
      },
      ConfigOptionUnexpectedFailure.new,
    );
  }
}

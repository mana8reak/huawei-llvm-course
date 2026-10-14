; ModuleID = 'src/app.c'
source_filename = "src/app.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nounwind optsize uwtable
define dso_local void @drawCell(i32 noundef %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
  %4 = shl nsw i32 %0, 2
  %5 = shl nsw i32 %1, 2
  br label %6

6:                                                ; preds = %3, %10
  %7 = phi i32 [ 0, %3 ], [ %11, %10 ]
  %8 = add nuw nsw i32 %7, %5
  br label %13

9:                                                ; preds = %10
  ret void

10:                                               ; preds = %13
  %11 = add nuw nsw i32 %7, 1
  %12 = icmp eq i32 %11, 4
  br i1 %12, label %9, label %6, !llvm.loop !5

13:                                               ; preds = %6, %13
  %14 = phi i32 [ 0, %6 ], [ %16, %13 ]
  %15 = add nuw nsw i32 %14, %4
  tail call void @simPutPixel(i32 noundef %15, i32 noundef %8, i32 noundef %2) #8
  %16 = add nuw nsw i32 %14, 1
  %17 = icmp eq i32 %16, 4
  br i1 %17, label %10, label %13, !llvm.loop !7
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: optsize
declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: nofree norecurse nosync nounwind optsize memory(argmem: write) uwtable
define dso_local void @createMap(ptr nocapture noundef writeonly %0) local_unnamed_addr #3 {
  %2 = getelementptr i32, ptr %0, i64 192
  br label %3

3:                                                ; preds = %1, %15
  %4 = phi i64 [ 0, %1 ], [ %16, %15 ]
  %5 = icmp eq i64 %4, 0
  %6 = icmp eq i64 %4, 191
  %7 = mul nuw nsw i64 %4, 384
  %8 = trunc i64 %4 to i32
  %9 = urem i32 %8, 25
  %10 = icmp ult i32 %9, 12
  %11 = getelementptr i32, ptr %2, i64 %7
  %12 = getelementptr i32, ptr %0, i64 %7
  %13 = getelementptr i32, ptr %0, i64 %7
  br label %18

14:                                               ; preds = %15
  ret void

15:                                               ; preds = %34
  %16 = add nuw nsw i64 %4, 1
  %17 = icmp eq i64 %16, 192
  br i1 %17, label %14, label %3, !llvm.loop !8

18:                                               ; preds = %3, %34
  %19 = phi i64 [ 0, %3 ], [ %35, %34 ]
  %20 = icmp eq i64 %19, 0
  %21 = icmp eq i64 %19, 383
  %22 = or i1 %20, %21
  %23 = or i1 %5, %22
  %24 = or i1 %6, %23
  br i1 %24, label %25, label %27

25:                                               ; preds = %18
  %26 = getelementptr i32, ptr %13, i64 %19
  store i32 1, ptr %26, align 4, !tbaa !9
  br label %34

27:                                               ; preds = %18
  %28 = icmp eq i64 %19, 192
  br i1 %28, label %29, label %32

29:                                               ; preds = %27
  br i1 %10, label %30, label %31

30:                                               ; preds = %29
  store i32 1, ptr %11, align 4, !tbaa !9
  br label %34

31:                                               ; preds = %29
  store i32 0, ptr %11, align 4, !tbaa !9
  br label %34

32:                                               ; preds = %27
  %33 = getelementptr i32, ptr %12, i64 %19
  store i32 0, ptr %33, align 4, !tbaa !9
  br label %34

34:                                               ; preds = %25, %30, %31, %32
  %35 = add nuw nsw i64 %19, 1
  %36 = icmp eq i64 %35, 384
  br i1 %36, label %15, label %18, !llvm.loop !13
}

; Function Attrs: nofree norecurse nosync nounwind optsize memory(argmem: readwrite) uwtable
define dso_local void @calcWave(ptr nocapture noundef readonly %0, ptr nocapture noundef %1, ptr nocapture noundef readonly %2) local_unnamed_addr #4 {
  br label %4

4:                                                ; preds = %3, %8
  %5 = phi i64 [ 1, %3 ], [ %9, %8 ]
  %6 = mul nuw nsw i64 %5, 384
  br label %11

7:                                                ; preds = %8
  ret void

8:                                                ; preds = %36
  %9 = add nuw nsw i64 %5, 1
  %10 = icmp eq i64 %9, 191
  br i1 %10, label %7, label %4, !llvm.loop !14

11:                                               ; preds = %4, %36
  %12 = phi i64 [ 1, %4 ], [ %37, %36 ]
  %13 = add nuw nsw i64 %12, %6
  %14 = getelementptr inbounds i32, ptr %2, i64 %13
  %15 = load i32, ptr %14, align 4, !tbaa !9
  %16 = icmp eq i32 %15, 1
  br i1 %16, label %36, label %17

17:                                               ; preds = %11
  %18 = getelementptr i32, ptr %0, i64 %13
  %19 = getelementptr i32, ptr %18, i64 -384
  %20 = load i32, ptr %19, align 4, !tbaa !9
  %21 = getelementptr i32, ptr %18, i64 384
  %22 = load i32, ptr %21, align 4, !tbaa !9
  %23 = add nsw i32 %22, %20
  %24 = getelementptr i32, ptr %18, i64 -1
  %25 = load i32, ptr %24, align 4, !tbaa !9
  %26 = add nsw i32 %23, %25
  %27 = getelementptr i32, ptr %18, i64 1
  %28 = load i32, ptr %27, align 4, !tbaa !9
  %29 = add nsw i32 %26, %28
  %30 = sdiv i32 %29, 2
  %31 = getelementptr inbounds i32, ptr %1, i64 %13
  %32 = load i32, ptr %31, align 4, !tbaa !9
  %33 = sub nsw i32 %30, %32
  %34 = ashr i32 %33, 7
  %35 = sub nsw i32 %33, %34
  store i32 %35, ptr %31, align 4, !tbaa !9
  br label %36

36:                                               ; preds = %11, %17
  %37 = add nuw nsw i64 %12, 1
  %38 = icmp eq i64 %37, 383
  br i1 %38, label %8, label %11, !llvm.loop !15
}

; Function Attrs: nounwind optsize uwtable
define dso_local void @drawField(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #0 {
  br label %3

3:                                                ; preds = %2, %9
  %4 = phi i64 [ 0, %2 ], [ %10, %9 ]
  %5 = mul nuw nsw i64 %4, 384
  %6 = trunc i64 %4 to i32
  %7 = trunc i64 %4 to i32
  br label %12

8:                                                ; preds = %9
  ret void

9:                                                ; preds = %41
  %10 = add nuw nsw i64 %4, 1
  %11 = icmp eq i64 %10, 192
  br i1 %11, label %8, label %3, !llvm.loop !16

12:                                               ; preds = %3, %41
  %13 = phi i64 [ 0, %3 ], [ %42, %41 ]
  %14 = add nuw nsw i64 %13, %5
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  %16 = load i32, ptr %15, align 4, !tbaa !9
  %17 = icmp eq i32 %16, 1
  br i1 %17, label %18, label %20

18:                                               ; preds = %12
  %19 = trunc i64 %13 to i32
  tail call void @drawCell(i32 noundef %19, i32 noundef %7, i32 noundef -8355712) #9
  br label %41

20:                                               ; preds = %12
  %21 = getelementptr inbounds i32, ptr %0, i64 %14
  %22 = load i32, ptr %21, align 4, !tbaa !9
  %23 = icmp slt i32 %22, 0
  %24 = sub nsw i32 0, %22
  %25 = tail call i32 @llvm.smin.i32(i32 %24, i32 255)
  %26 = icmp sgt i32 %22, 0
  %27 = ashr i32 %22, 2
  %28 = tail call i32 @llvm.smin.i32(i32 %27, i32 255)
  %29 = mul nsw i32 %22, %22
  %30 = lshr i32 %29, 5
  %31 = tail call i32 @llvm.umin.i32(i32 %30, i32 255)
  %32 = shl i32 %25, 16
  %33 = shl i32 %28, 8
  %34 = select i1 %26, i32 %31, i32 0
  %35 = or i32 %32, -16777216
  %36 = select i1 %23, i32 %35, i32 -16777216
  %37 = select i1 %26, i32 %33, i32 0
  %38 = or i32 %36, %37
  %39 = or disjoint i32 %38, %34
  %40 = trunc i64 %13 to i32
  tail call void @drawCell(i32 noundef %40, i32 noundef %6, i32 noundef %39) #9
  br label %41

41:                                               ; preds = %20, %18
  %42 = add nuw nsw i64 %13, 1
  %43 = icmp eq i64 %42, 384
  br i1 %43, label %9, label %12, !llvm.loop !17
}

; Function Attrs: nofree norecurse nosync nounwind optsize memory(argmem: readwrite) uwtable
define dso_local void @addSplash(ptr nocapture noundef writeonly %0, ptr nocapture noundef readonly %1, i32 noundef %2) local_unnamed_addr #4 {
  %4 = lshr i32 %2, 16
  %5 = trunc i32 %4 to i16
  %6 = sdiv i16 %5, 4
  %7 = sext i16 %6 to i32
  %8 = lshr i32 %2, 2
  %9 = and i32 %8, 16383
  br label %10

10:                                               ; preds = %3, %17
  %11 = phi i32 [ -1, %3 ], [ %18, %17 ]
  %12 = add nsw i32 %11, %9
  %13 = icmp sgt i32 %12, 0
  %14 = icmp slt i32 %12, 191
  %15 = mul nuw nsw i32 %12, 384
  br label %20

16:                                               ; preds = %17
  ret void

17:                                               ; preds = %35
  %18 = add nsw i32 %11, 1
  %19 = icmp eq i32 %18, 2
  br i1 %19, label %16, label %10, !llvm.loop !18

20:                                               ; preds = %10, %35
  %21 = phi i32 [ -1, %10 ], [ %36, %35 ]
  %22 = add nsw i32 %21, %7
  %23 = add nsw i32 %22, -1
  %24 = icmp ult i32 %23, 382
  %25 = select i1 %24, i1 %13, i1 false
  %26 = select i1 %25, i1 %14, i1 false
  br i1 %26, label %27, label %35

27:                                               ; preds = %20
  %28 = add nuw nsw i32 %22, %15
  %29 = zext nneg i32 %28 to i64
  %30 = getelementptr inbounds i32, ptr %1, i64 %29
  %31 = load i32, ptr %30, align 4, !tbaa !9
  %32 = icmp eq i32 %31, 1
  br i1 %32, label %35, label %33

33:                                               ; preds = %27
  %34 = getelementptr inbounds i32, ptr %0, i64 %29
  store i32 1500, ptr %34, align 4, !tbaa !9
  br label %35

35:                                               ; preds = %33, %27, %20
  %36 = add nsw i32 %21, 1
  %37 = icmp eq i32 %36, 2
  br i1 %37, label %17, label %20, !llvm.loop !19
}

; Function Attrs: noreturn nounwind optsize uwtable
define dso_local void @app() local_unnamed_addr #5 {
  %1 = alloca [73728 x i32], align 16
  %2 = alloca [73728 x i32], align 16
  %3 = alloca [73728 x i32], align 16
  call void @llvm.lifetime.start.p0(i64 294912, ptr nonnull %1) #10
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(294912) %1, i8 0, i64 294912, i1 false)
  call void @llvm.lifetime.start.p0(i64 294912, ptr nonnull %2) #10
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(294912) %2, i8 0, i64 294912, i1 false)
  call void @llvm.lifetime.start.p0(i64 294912, ptr nonnull %3) #10
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(294912) %3, i8 0, i64 294912, i1 false)
  call void @createMap(ptr noundef nonnull %1) #9
  br label %4

4:                                                ; preds = %24, %0
  %5 = phi ptr [ %3, %0 ], [ %6, %24 ]
  %6 = phi ptr [ %2, %0 ], [ %5, %24 ]
  call void @drawField(ptr noundef %6, ptr noundef nonnull %1) #9
  tail call void (...) @simFlush() #8
  call void @calcWave(ptr noundef %6, ptr noundef %5, ptr noundef nonnull %1) #9
  %7 = tail call i32 (...) @simHasClick() #8
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %13, label %9

9:                                                ; preds = %4, %9
  %10 = tail call i32 (...) @simGetClick() #8
  call void @addSplash(ptr noundef %5, ptr noundef nonnull %1, i32 noundef %10) #9
  %11 = tail call i32 (...) @simHasClick() #8
  %12 = icmp eq i32 %11, 0
  br i1 %12, label %13, label %9, !llvm.loop !20

13:                                               ; preds = %9, %4
  %14 = tail call i32 (...) @simRand() #8
  %15 = srem i32 %14, 100
  %16 = icmp eq i32 %15, 0
  br i1 %16, label %17, label %24

17:                                               ; preds = %13
  %18 = tail call i32 (...) @simRand() #8
  %19 = srem i32 %18, 1536
  %20 = shl nsw i32 %19, 16
  %21 = tail call i32 (...) @simRand() #8
  %22 = srem i32 %21, 768
  %23 = or i32 %20, %22
  call void @addSplash(ptr noundef %5, ptr noundef nonnull %1, i32 noundef %23) #9
  br label %24

24:                                               ; preds = %17, %13
  br label %4
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #6

; Function Attrs: optsize
declare void @simFlush(...) local_unnamed_addr #2

; Function Attrs: optsize
declare i32 @simHasClick(...) local_unnamed_addr #2

; Function Attrs: optsize
declare i32 @simGetClick(...) local_unnamed_addr #2

; Function Attrs: optsize
declare i32 @simRand(...) local_unnamed_addr #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #7

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umin.i32(i32, i32) #7

attributes #0 = { nounwind optsize uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree norecurse nosync nounwind optsize memory(argmem: write) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree norecurse nosync nounwind optsize memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { noreturn nounwind optsize uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #7 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { nounwind optsize }
attributes #9 = { optsize }
attributes #10 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 18.1.8 (++20240731025043+3b5b5c1ec4a3-1~exp1~20240731145144.92)"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = !{!10, !10, i64 0}
!10 = !{!"int", !11, i64 0}
!11 = !{!"omnipotent char", !12, i64 0}
!12 = !{!"Simple C/C++ TBAA"}
!13 = distinct !{!13, !6}
!14 = distinct !{!14, !6}
!15 = distinct !{!15, !6}
!16 = distinct !{!16, !6}
!17 = distinct !{!17, !6}
!18 = distinct !{!18, !6}
!19 = distinct !{!19, !6}
!20 = distinct !{!20, !6}
